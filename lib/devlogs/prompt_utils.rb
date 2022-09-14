require "tty-prompt"

module PromptUtils
  def build_select_prompt(data:) 
    prompt = TTY::Prompt.new

    prompt.select("Select log entry") do |menu|
      data.each_with_index do |d, index|
        menu.choice d, index
      end
    end
  end
end
