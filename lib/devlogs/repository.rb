# frozen_string_literal: true

require "fileutils"
require "tty-prompt"
require "pry"
require "time"

require_relative "repository/config_store"
require_relative "editor"
require_relative "repository/sync_manager"
require_relative "log_template"

# Repostiroy is an accessor object for the devlogs directory
class Repository
  # Example: 11-22-2022_1343
  TIME_FORMAT_FILE_PREFIX = "%m-%d-%Y__%kh%Mm"

  LOG_FILE_SUFFIX="log.md"
  ISSUE_FILE_PREFIX="iss"

  VALID_DIRECTION = %i[asc desc].freeze

  # Initializes a .devlogs repository with the supplied configuration
  #
  def initialize(repo_config_store)
    @config_store = repo_config_store
    @repo_config = @config_store.values
  end

  # Creates a new .devlogs entry for recording session completion
  #
  # @returns nil
  def create
    time = Time.new
    time_prefix = time.strftime(TIME_FORMAT_FILE_PREFIX)

    entry_file_name = "#{time_prefix}_#{LOG_FILE_SUFFIX}"

    # FIXME: Need to figure out file path
    entry_file_path = File.join(@config_store.dir, entry_file_name)

    # FIXME: Need to figure out file path
    template = LogTemplate.new(@config_store.template_file_path)

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
    if @repo_config.mirror?
      sync_manager.run
    end
  end

  # Lists the files in the repository
  def ls(direction = :desc)
    raise ArgumentError, "Must be one of: " + VALID_DIRECTION unless VALID_DIRECTION.include?(direction.to_sym)

    Dir.glob(File.join(@config_store.dir, "*_#{LOG_FILE_SUFFIX}")).sort_by do |fpath|
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
    def load(path = File.join(Repository::ConfigStore::DEFAULT_DIRECTORY_PATH, Repository::ConfigStore::DEFAULT_DIRECTORY_NAME))

      store = Repository::ConfigStore.load_from(path)

      new(store)
    end
  end

  private
  def sync_manager
    @sync_manager ||= Repository::SyncManager.new(@config_store)
  end
end
