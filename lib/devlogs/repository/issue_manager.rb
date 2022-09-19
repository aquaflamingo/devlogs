require_relative '../helper/time_helper'
require_relative '../helper/tty_prompt_helper'
require_relative "../render/issue_template_renderer"

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
    raise NotImplementedError
  end

  # 
  # Adds a new entry to the repository 
  #
  # @returns [String] entry file path
  #
  def create
    info = issue_info_prompt

    issue = compose_issue(info)

    issue_file_path = File.join(@config_store.issue_dir_path, issue[:file_name])

    template = IssueTemplateRenderer.new(@config_store.issue_template_file_path, issue)

    unless File.exist?(issue_file_path)
      # Add default boiler plate if the file does not exist yet
      File.open(issue_file_path, "w") do |f|
        f.write template.render
      end

      increment_issue_index!
    end

    issue_file_path
  end

  private

  #
  # Sanitizes and composes the content for display
  #
  # @returns [Hash]
  def compose_issue(info = {}) 
    # RLP-n
    short_code_issue = compute_short_code

    # RLP-1: User Validation Fails.md
    display_title = "#{short_code_issue}: #{info[:title]}"

    #rlp_1__user_validation_fails.md
    file_name_title = snakify(info[:title])

    issue_file_name = "#{short_code_issue}__#{file_name_title}.md".downcase

    {
      display_title: display_title,
      file_name: issue_file_name,
      description: info[:description].join(""),
      reproduction: info[:reproduction].join(""),
    }
  end

  #
  # Increments the issue index in the data file by one
  #
  def increment_issue_index!
    data = YAML.load_file(@config_store.data_file_path)

    data[:issues][:index] += 1

    File.open(@config_store.data_file_path, "w") do |f|
      f.write data.to_yaml
    end
  end

  def issue_info_prompt
    prompt = TTY::Prompt.new

    prompt.collect do
      key(:title).ask("What is the issue title?") do |q|
        q.required true 
        q.validate Validator.length_range(min: 0, max: 25)
        q.messages[:valid?] = "Title cannot be empty and may be maximum 25 characters"
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
    data = YAML.load_file(@config_store.data_file_path)

    issue_index = data[:issues][:index]

    "#{config_values.short_code}-#{issue_index}".upcase
  end
end
