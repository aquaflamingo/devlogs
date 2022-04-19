# frozen_string_literal: true

require "fileutils"
require "tty-prompt"
require "yaml"
require "rsync"
require "pry"

# Repostiroy is an accessor object for the devlogs directory
class Repository
  CONFIG_FILE = ".devlogs.config.yml"

  # TODO: should be part of configuration
  DEFAULT_LOG_SUFFIX = "devlogs.md"
  DEFAULT_DIRECTORY_PATH = "."
  DEFAULT_DIRECTORY_NAME = "__devlogs"

  # Example: 11-22-2022_1343
  DEFAULT_TIME_FORMAT_FILE_PREFIX = "%m-%d-%Y__%kh%Mm"
  DEFAULT_TIME_FORMAT_TEXT_ENTRY = "%m-%d-%Y %k:%M"

  # Initializes a __devlogs repository with the supplied configuration
  # @param repo_config [Repository::Config]
  #
  def initialize(repo_config)
    @config = repo_config
  end

  # Creates a new __devlogs entry for recording session completion
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

    editor_program = ENV["EDITOR"]

    system("#{editor_program} #{entry_file_path}")

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
      path = @config.path[-1] == "/" ? @config.path : @config.path + "/"

      Rsync.run("-av", path, @config.mirror.path) do |result|
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
    attr_reader :name, :description, :mirror, :path

    MirrorConfig = Struct.new(:use_mirror, :path, keyword_init: true)

    def initialize(name, desc, mirror, p)
      @name = name
      @description = desc
      @mirror = MirrorConfig.new(mirror)
      @path = p
    end

    # Returns whether or not the devlogs repository is configured to mirror
    #
    # @returns [Boolean]
    def mirror?
      @mirror.use_mirror
    end

    # Utility method to build a configuration from a Hash
    #
    # @returns [Repository::Config]
    def self.hydrate(cfg)
      new(cfg[:name], cfg[:description], cfg[:mirror], cfg[:path])
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
        File.open(File.join(path), "a") do |f|
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
