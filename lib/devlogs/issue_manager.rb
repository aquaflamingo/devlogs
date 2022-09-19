require_relative 'helper/time_helper'
require_relative 'helper/tty_prompt_helper'

class IssueManager
  include TTYPromptHelper
  include TimeHelper

  VALID_DIRECTION = %i[asc desc].freeze

  def initialize(repo_config_store)
    @config_store = repo_config_store
  end

  # Lists the issue entries present in the repository 
  #
  # @param direction [Symbol] ascending or descending 
  #
  def list(direction = :desc)
    # TODO
    raise NotImplementedError
  end

  # 
  # Adds a new entry to the repository 
  #
  # @returns [String] entry file path
  #
  def create
    info = issue_info_prompt

    short_code_issue = compute_short_code

    # RLP-1: User Validation Fails.md
    display_title = "#{short_code_issue}: #{info[:title]}"

    info[:title] = display_title

    file_name_title = snakify(info[:title])

    #rlp_1__user_validation_fails.md
    entry_file_name = "#{short_code_issue}__#{file_name_title}.md".downcase

    entry_file_path = File.join(@config_store.issue_dir_path, entry_file_name)

    template = IssueTemplate.new(@config_store.issue_template_file_path, info)

    unless File.exist?(entry_file_path)
      # Add default boiler plate if the file does not exist yet
      File.open(entry_file_path, "w") do |f|
        f.write template.render
      end
    end

    entry_file_path
  end

  private

  def issue_info_prompt
    prompt = TTY::Prompt.new

    prompt.collect do
      key(:title).ask("What is the issue title?") do |q|
        q.required true 
        q.validate Validator.length_range(min: 0, max: 25)
      end

      key(:description).multiline("Describe the issue: ") do |q|

        q.default "There is an issue with..."
        q.help "Press ctrl+d to end"
      end

      key(:reproduction).multiline("Describe the reproduction steps: ") do |q|
        q.default "To reproduce the issue..."
        q.help "Press ctrl+d to end"
      end
    end
  end

  def config_values
    @config_store.values
  end

  # Transforms a string with spaces or hyphens to 
  # an snake case string
  def snakify(input)
    input.gsub(/[ -]/,"_").downcase
  end

  # 
  # Reads the .data.yml file in the repository to 
  # get the latest issue index number
  #
  # @returns [String]
  #
  def compute_short_code
    yml = YAML.load_file(@config_store.data_file_path)

    issue_index = yml[:issues][:index]

    "#{config_values.short_code}-#{issue_index}".upcase
  end
end
