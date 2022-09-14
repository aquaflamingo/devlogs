# frozen_string_literal: true

require "tty-prompt"

#
# Utility module for tty-prompt library
#
module PromptUtils
  #
  # Builds a basic select prompt using the provided data
  #
  # @param data [Array<String>]
  #
  # @returns String
  #
  def build_select_prompt(data:, text:)
    ttyprompt = TTY::Prompt.new

    ttyprompt.select(text) do |menu|
      data.each_with_index do |d, index|
        menu.choice d, index
      end
    end
  end
end
