require "yaml"
require "rsync"

require_relative "config"

# A per repository configuration storage directory
class Repository
  class ConfigStore
    attr_reader :dir, :values

    CONFIG_FILE = ".devlogs.config.yml"

    # TODO: should be part of configuration
    TEMPLATE_FILE = ".log_template.erb.md"
    DEFAULT_DIRECTORY_PATH = "."
    DEFAULT_DIRECTORY_NAME = ".devlogs"

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

      Repository::Config.new(file_path, yml)
    end
  end
end
