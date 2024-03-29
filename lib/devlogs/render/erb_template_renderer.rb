# frozen_string_literal: true

require "erb"

#
# ErbTemplateRenderer is a base class for rendering arbitrary
# ERB templates.
#
class ErbTemplateRenderer
  attr_reader :time

  TIME_FORMAT_TEXT_ENTRY = "%m-%d-%Y %k:%M"

  def initialize(template_file_path)
    @time = Time.new.strftime(TIME_FORMAT_TEXT_ENTRY)
    @template_file_path = template_file_path
  end

  #
  # Runs the ERB rendering using the provided template file template_file_path
  #
  # @returns [String]
  #
  def render
    erb = ERB.new(File.read(@template_file_path))
    erb.result(get_binding)
  end

  # rubocop:disable
  #
  # For ERB
  #
  def get_binding
    binding
  end
end
