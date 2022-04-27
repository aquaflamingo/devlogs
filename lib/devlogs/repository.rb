# frozen_string_literal: true

require "fileutils"
require "tty-prompt"
require "yaml"
require "rsync"
require "pry"
require "time"
require_relative "editor"

# Repostiroy is an accessor object for the devlogs directory
class Repository
  CONFIG_FILE = ".devlogs.config.yml"

  # TODO: should be part of configuration
  DEFAULT_LOG_SUFFIX = "devlogs.md"
  DEFAULT_DIRECTORY_PATH = "."
  DEFAULT_DIRECTORY_NAME = "_devlogs"

  # Example: 11-22-2022_1343
  DEFAULT_TIME_FORMAT_FILE_PREFIX = "%m-%d-%Y__%kh%Mm"
  DEFAULT_TIME_FORMAT_TEXT_ENTRY = "%m-%d-%Y %k:%M"

  VALID_DIRECTION = %i[asc desc].freeze

  # Initializes a _devlogs repository with the supplied configuration
  # @param repo_config [Repository::Config]
  #
  def initialize(repo_config)
    @config = repo_config
@mirror_manager = MirrorManager.new(@config.mi
  end

  # Creates a new _devlogs entry for recording session completion
  #
  # @returns nil
  def create
    time = Time.new
    prefix = time.strftime(DEFAULT_TIME_FORMAT_FILE_PREFIX)

    entry_file_name = "#{prefix}_#{DEFAULT_LOG_SUFFIX}"

    entry_file_path = File.join(@config.path, entry_file_name)

    unless File.exist?(entry_file_path)
      # Add default boiler plate if the file does not exist yet
      File.open(entry_file_path, "w") do |f|
        f.write <<~ENDOFFILE
          # #{time.strftime(DEFAULT_TIME_FORMAT_TEXT_ENTRY)}
          Tags: #dev, #log

          What did you do today?

        ENDOFFILE
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
    def load(path = File.join(DEFAULT_DIRECTORY_PATH, DEFAULT_DIRECTORY_NAME))
      exists = File.exist?(path)

      raise "no repository found #{path}" unless exists

      cfg = YAML.load_file(File.join(path, CONFIG_FILE))

      cfg[:path] = path

      repo_config = Config.hydrate(cfg)

      new(repo_config)
    end
  end

  # Config is a configuration data object for storing Repository configuration
  # in memory for access.
  class Config
    attr_reader :name, :description, :mirror, :path_value

    # Configuration associated with the Mirror
    MirrorConfig = Struct.new(:use_mirror, :path, keyword_init: true)

    def initialize(name, desc, mirror, p)
      @name = name
      @description = desc
      @mirror = MirrorConfig.new(mirror)
      @path_value = p
    end

    # Returns whether or not the devlogs repository is configured to mirror
    #
    # @returns [Boolean]
    def mirror?
      @mirror.use_mirror
    end

    def path(with_trailing: false)
      if with_trailing
        @path_value[-1] == "/" ? @path_value : @path_value + "/"
      else
        @path_value
      end
    end

    # Utility method to build a configuration from a Hash
    #
    # @returns [Repository::Config]
    def self.hydrate(cfg)
      new(cfg[:name], cfg[:description], cfg[:mirror], cfg[:path])
    end
  end

  class MirrorManager
    def initialize(mirror)
      @mirror_config = mirror
    end

    def mirror?
      # TODO: Refactor config
    end
  end

  # Initialize is an execution object which initializes a Repository on the
  # filesystem
  class Initialize
    # Creates a new devlogs repository at the provided path
    def self.run(opts = {}, path = File.join(DEFAULT_DIRECTORY_PATH, DEFAULT_DIRECTORY_NAME))
      exists = File.exist?(path)

      if exists && !opts[:force]
        puts "Log repository already exists in #{path}. Aborting..."
        raise RuntimeError
      end

      results = prompt_for_info

      FileUtils.mkdir_p(path)
      config_file = File.join(path, CONFIG_FILE)

      # Replace spaces in project name with underscores
      sanitized_project_name = results[:name].gsub(/ /, "_").downcase

      info_file_name = "#{sanitized_project_name}_devlogs.info.md"
      info_file = File.join(path, info_file_name)

      # Create config file
      File.open(config_file, "w") do |f|
        f.write results.to_yaml
      end

      # Create the info file
      File.open(info_file, "w") do |f|
        f.puts "# #{results[:name]}"
        f.puts (results[:desc]).to_s
      end

      # Git ignore if specified
      if results[:gitignore]
        gitignore = File.join(path, ".gitignore")

        File.open(gitignore, "a") do |f|
          f.puts DEFAULT_DIRECTORY_NAME
        end
      end
    end

    # Creates an interactive prompt for user input
    #
    # @returns [Hash]
    def self.prompt_for_info
      prompt = TTY::Prompt.new

      prompt.collect do |_p|
        # Project name
        key(:name).ask("What is the project name?") do |q|
          q.required true
        end

        # Project description
        key(:desc).ask("What is the project description?") do |q|
          q.required true
        end

        key(:mirror) do
          key(:use_mirror).ask("Do you want to mirror these logs?", convert: :boolean)
          key(:path).ask("Path to mirror directory: ")
        end

        key(:gitignore).ask("Do you want to gitignore the devlogs repository?") do |q|
          q.required true
        end
      end
    end
  end
end
