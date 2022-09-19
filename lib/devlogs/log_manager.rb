require_relative 'helper/time_helper'
require_relative "erb_template"

class LogManager
  include TimeHelper
  LOG_FILE_SUFFIX = "log.md"
  VALID_DIRECTION = %i[asc desc].freeze

  def initialize(repo_config_store)
    @config_store = repo_config_store
  end

  # Lists the log entries present in the repository 
  #
  # @param direction [Symbol] ascending or descending 
  #
  def list_entries(direction = :desc)
    raise ArgumentError, "Must be one of: " + VALID_DIRECTION unless VALID_DIRECTION.include?(direction.to_sym)

    # Anything with the _log.md suffix
    glob_pattern = File.join(@config_store.dir, "*_#{LOG_FILE_SUFFIX}")

    Dir.glob(glob_pattern).sort_by do |fpath|
      # The date is joined by two underscores to the suffix
      date, = File.basename(fpath).split("_#{LOG_FILE_SUFFIX}")

      time_ms = Time.strptime(date, TimeHelper::TIME_FORMAT_FILE_PREFIX).to_i

      if direction == :asc
        time_ms
      else
        -time_ms
      end
    end
  end

  # 
  # Adds a new entry to the repository 
  #
  # @returns [String] entry file path
  #
  def create_entry
    entry_file_name = "#{current_time}_#{LOG_FILE_SUFFIX}"

    entry_file_path = File.join(@config_store.dir, entry_file_name)

    template = LogTemplate.new(@config_store.template_file_path)

    unless File.exist?(entry_file_path)
      # Add default boiler plate if the file does not exist yet
      File.open(entry_file_path, "w") do |f|
        f.write template.render
      end
    end

    entry_file_path
  end
end
