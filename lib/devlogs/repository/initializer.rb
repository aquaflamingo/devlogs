# frozen_string_literal: true

require_relative "config_store"

# Initialize is an execution object which initializes a Repository on the
# filesystem
class Repository
  class Initializer
    INFO_FILE_SUFFIX = "devlogs.info.md"
    LOG_TEMPLATE_FILE_NAME = "__log_template.erb.md"

    # Creates a new devlogs repository at the provided path
    def self.run(opts = {})
      new_config = if opts[:dir_path]
                     Repository::ConfigStore.new(dir: opts[:dir_path])
                   else
                     Repository::ConfigStore.new
                   end

      exists = File.exist?(new_config.file_path)

      if exists && !opts[:force]
        puts "Log repository already exists in #{new_config.file_path}. Aborting..."
        raise RuntimeError
      end

      results = prompt_for_info

      # Create the new_config directory
      FileUtils.mkdir_p(new_config.dir)

      # Create new_config file
      File.open(new_config.file_path, "w") do |f|
        f.write results.to_yaml
      end

      # Replace spaces in project name with underscores
      sanitized_project_name = results[:name].gsub(/ /, "_").downcase

      # Create the info file
      info_file_name = "#{sanitized_project_name}.devlogs.info.md"
      info_file = File.join(new_config.dir, info_file_name)

      File.open(info_file, "w") do |f|
        f.puts "# #{results[:name]}"
        f.puts (results[:desc]).to_s
      end

      # Copy the default template file inside the gem into the repository
      default_template_path = get_template_path

      new_config_template_file_path = File.join(new_config.dir, Repository::ConfigStore::TEMPLATE_FILE)

      FileUtils.cp(default_template_path, new_config_template_file_path)
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
      end
    end

    # Gets the template file path embedded in the gem from the library root
    def self.get_template_path
      File.join(Devlogs.lib_root, "templates", LOG_TEMPLATE_FILE_NAME)
    end
  end
end
