require "yaml"
require "rsync"

# A per repository configuration storage directory
class RepositoryConfigStore
  attr_reader :dir, :values

  CONFIG_FILE = ".devlogs.config.yml"

  # TODO: should be part of configuration
  TEMPLATE_FILE = ".log_template.erb.md"
  DEFAULT_DIRECTORY_PATH = "."
  DEFAULT_DIRECTORY_NAME = "_devlogs"

  def initialize(dir: File.join(DEFAULT_DIRECTORY_PATH, DEFAULT_DIRECTORY_NAME))
    @dir = dir 
  end

  def values
    @values ||= load_values_from_config_file
  end

  def file_path
    File.join(@dir, CONFIG_FILE)
  end

  def template_file_path
    File.join(@dir, TEMPLATE_FILE)
  end

  class << self
    def load_from(path = File.join(DEFAULT_DIRECTORY_PATH, DEFAULT_DIRECTORY_NAME))
      exists = File.exist?(path)

      raise "no repository found #{path}" unless exists

      new(dir: path)
    end
  end

  private 
  def load_values_from_config_file
    yml = YAML.load_file(File.join(file_path))

    RepositoryConfig.new(file_path, yml)
  end

  # The repository's configuration values located in the yml file
  class RepositoryConfig
    # FIXME: Need to figure out file path
    attr_reader :name, :description, :mirror, :file_path, :template_file_path

    # Configuration associated with the Mirror
    MirrorConfig = Struct.new(:use_mirror, :path, keyword_init: true)

    def initialize(path, opts = {})
      @file_path = path
      @template_file_path = opts[:template_file_path]
      @name = opts[:name]
      @description = opts[:description]
      @mirror = MirrorConfig.new(opts[:mirror])
    end

    # Returns whether or not the devlogs repository is configured to mirror
    #
    # @returns [Boolean]
    def mirror?
      @mirror.use_mirror
    end

    # Ensures no weird double trailing slash path values
    def path(with_trailing: false)
      if with_trailing
        @file_path[-1] == "/" ? @path_value : @path_value + "/"
      else
        @file_path
      end
    end
  end
end
