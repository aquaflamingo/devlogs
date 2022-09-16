# frozen_string_literal: true

require "fileutils"
require "tty-prompt"
require "rsync"
require "pry"
require "time"

require_relative "repository_config_store"
require_relative "editor"
require_relative "log_template"

# Repostiroy is an accessor object for the devlogs directory
class Repository
  # Example: 11-22-2022_1343
  TIME_FORMAT_FILE_PREFIX = "%m-%d-%Y__%kh%Mm"

  LOG_FILE_SUFFIX="log.md"
  ISSUE_FILE_PREFIX="iss"

  VALID_DIRECTION = %i[asc desc].freeze

  # Initializes a _devlogs repository with the supplied configuration
  #
  def initialize(repo_config)
    @config = repo_config
  end

  # Creates a new _devlogs entry for recording session completion
  #
  # @returns nil
  def create
    time = Time.new
    time_prefix = time.strftime(TIME_FORMAT_FILE_PREFIX)

    entry_file_name = "#{time_prefix}_#{LOG_FILE_SUFFIX}"

    entry_file_path = File.join(@config.path, entry_file_name)

    template = LogTemplate.new(@config.template_file_path)

    unless File.exist?(entry_file_path)
      # Add default boiler plate if the file does not exist yet
      File.open(entry_file_path, "w") do |f|
        f.write template.render 
      end
    end

    Editor.open(entry_file_path)

    puts "Writing entry to #{entry_file_path}.."
  end

  # Syncs the directory changes to the (optional) mirror repository
  # specified in the configuration.
  #
  # @returns nil
  def sync
    if @config.mirror?
      # Run rsync with -a to copy directories recursively

      # Use trailing slash to avoid sub-directory
      # See rsync manual page

      Rsync.run("-av", @config.path(with_trailing: true), @config.mirror.path) do |result|
        if result.success?
          puts "Mirror sync complete."
          result.changes.each do |change|
            puts "#{change.filename} (#{change.summary})"
          end
        else
          raise "Failed to sync: #{result.error}"
        end
      end
    end
  end

  # Lists the files in the repository
  def ls(direction = :desc)
    raise ArgumentError, "Must be one of: " + VALID_DIRECTION unless VALID_DIRECTION.include?(direction.to_sym)

    Dir.glob(File.join(@config.path, "*_#{DEFAULT_LOG_SUFFIX}")).sort_by do |fpath|
      # The date is joined by two underscores to the suffix
      date, = File.basename(fpath).split("__")

      time_ms = Time.strptime(date, "%m-%d-%Y").to_i

      # Descending
      if direction == :asc
        time_ms
      else
        -time_ms
      end
    end
  end

  class << self
    # Loads a repository from the provided path
    #
    # @returns [Repository]
    #
    def load(path = File.join(RepositoryConfig::DEFAULT_DIRECTORY_PATH, RepositoryConfig::DEFAULT_DIRECTORY_NAME))

      store = RepositoryConfigStore.load_from(path)

      new(store.values)
    end
  end
end
