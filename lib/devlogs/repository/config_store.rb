# frozen_string_literal: true

require "yaml"
require "rsync"

require_relative "config"

# A per repository configuration storage directory
class Repository
  class ConfigStore
    attr_reader :dir

    CONFIG_FILE = ".devlogs.config.yml"
    DATA_FILE = ".devlogs.data.yml"
    ISSUE_TEMPLATE_FILE = ".issue_template.erb.md"
    LOG_TEMPLATE_FILE = ".log_template.erb.md"

    ISSUE_DIR = "issues"
    DEFAULT_DIRECTORY_PATH = "."
    DEFAULT_DIRECTORY_NAME = ".devlogs"

    def initialize(dir: File.join(DEFAULT_DIRECTORY_PATH, DEFAULT_DIRECTORY_NAME))
      @dir = dir
    end

    def values
      @values ||= load_values_from_config_file
    end

    #
    # Retrieves the data file
    #
    # @returns [String]
    #
    def data_file_path
      File.join(@dir, DATA_FILE)
    end

    #
    # Retrieves .devlogs.config.yml file path
    #
    # @returns [String]
    #
    def file_path
      File.join(@dir, CONFIG_FILE)
    end

    #
    # The template File
    #
    # @returns [String]
    # FIXME: rename to log_template_file_path
    def template_file_path
      File.join(@dir, LOG_TEMPLATE_FILE)
    end

    #
    # The issue template file path:
    #
    # @returns [String]
    #
    def issue_template_file_path
      File.join(@dir, ISSUE_TEMPLATE_FILE)
    end

    #
    # Issue directory path
    #
    # @returns [String]
    #
    def issue_dir_path
      File.join(@dir, ISSUE_DIR)
    end

    class << self
      #
      # Initialization utility method
      #
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
