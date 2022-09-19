# frozen_string_literal: true

class Repository
  class ConfigBuilder
    def initialize(dirpath)
      @config_store = if dirpath
                        Repository::ConfigStore.new(dir: dirpath)
                      else
                        Repository::ConfigStore.new
                      end
    end

    def build
      config_info = prompt_for_info

      DraftConfig.new(@config_store, config_info)
    end

    private

    # Creates an interactive prompt for user input
    #
    # @returns [Hash]
    def prompt_for_info
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

        # Project short code, e.g. RLP
        key(:short_code).ask("What is the project short code (3 letters)?") do |q|
          q.required true

          q.validate ->(input) { input.size.positive? && input.size <= 3 }

          q.messages[:valid?] = "Short code must be 3 letters or less"
        end

        key(:mirror) do
          key(:use_mirror).ask("Do you want to mirror these logs?", convert: :boolean)
          key(:path).ask("Path to mirror directory: ")
        end
      end
    end

    class DraftConfig
      INFO_FILE_SUFFIX = "devlogs.info.md"
      LOG_TEMPLATE_FILE_NAME = "__log_template.erb.md"
      ISSUE_TEMPLATE_FILE_NAME = "__issue_template.erb.md"

      def initialize(config_store, config_info)
        @config_store = config_store
        @config_info = config_info
      end

      #
      # Initiates the write process of devlogs repository
      #
      # @param force [Boolean]
      #
      def save!(force: false)
        exists = File.exist?(@config_store.file_path)

        if exists && !force
          puts "Log repository already exists in aborting..."
          raise RuntimeError
        end

        create_config_store_dir
        save_config_file
        save_info_file
        save_log_template_file

        create_issue_dir
        save_issue_template_file
        save_data_file
      end

      private

      #
      # Creates the configuration store directory
      #
      def create_config_store_dir
        # Create the draft_config directory
        FileUtils.mkdir_p(@config_store.dir)
      end

      #
      # Creates the issue directory
      #
      def create_issue_dir
        # Create the draft_config directory
        FileUtils.mkdir_p(@config_store.issue_dir_path)
      end

      #
      # Saves the .devlogs.config.yml file
      #
      def save_config_file
        # Create draft_config file
        File.open(@config_store.file_path, "w") do |f|
          f.write @config_info.to_yaml
        end
      end

      #
      # Saves the .info file
      #
      def save_info_file
        # Replace spaces in project name with underscores
        sanitized_project_name = @config_info[:name].gsub(/ /, "_").downcase

        # Create the info file
        info_file_name = "#{sanitized_project_name}.#{INFO_FILE_SUFFIX}"
        info_file = File.join(@config_store.dir, info_file_name)

        File.open(info_file, "w") do |f|
          f.puts "# #{@config_info[:name]}"
          f.puts (@config_info[:desc]).to_s
        end
      end

      #
      # Copies the log template to the config store directory
      #
      def save_log_template_file
        # Copy the default template file inside the gem into the repository
        default_log_template_path = get_template_path(LOG_TEMPLATE_FILE_NAME)

        draft_config_log_template_file_path = File.join(@config_store.dir, Repository::ConfigStore::LOG_TEMPLATE_FILE)

        FileUtils.cp(default_log_template_path, draft_config_log_template_file_path)
      end

      #
      # Copies the log template to the config store directory
      #
      def save_issue_template_file
        default_iss_template_path = get_template_path(ISSUE_TEMPLATE_FILE_NAME)

        draft_config_iss_template_file_path = File.join(@config_store.dir, Repository::ConfigStore::ISSUE_TEMPLATE_FILE)

        FileUtils.cp(default_iss_template_path, draft_config_iss_template_file_path)
      end

      #
      # Creates a .devlogs.data.yml file
      #
      def save_data_file
        data_file = File.join(@config_store.dir, Repository::ConfigStore::DATA_FILE)

        #
        # MARK: Default Data
        #
        data_info = {
          issues: {
            index: 1
          },
          logs: {},
          repository: {}
        }

        File.open(data_file, "w") do |f|
          f.puts data_info.to_yaml
        end
      end

      # Gets the template file path embedded in the gem from the library root
      #
      # @returns [String]
      #
      def get_template_path(file_name)
        File.join(Devlogs.lib_root, "templates", file_name)
      end
    end
  end
end
