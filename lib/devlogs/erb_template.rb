# frozen_string_literal: true
require "erb"

#
# ErbTemplate is a class that represents the rendered template
#
class ErbTemplate
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


# TODO: Move to templates folder
class LogTemplate < ErbTemplate 
end

# TODO: Move to templates folder
class IssueTemplate < ErbTemplate
  attr_reader :title, :description, :reproduction

  def initialize(template_file_path, info = {})
    super(template_file_path)

    @title = info[:title]
    @description = info[:description]
    @reproduction = info[:reproduction]
  end
end
