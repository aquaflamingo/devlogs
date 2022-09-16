require 'erb'

class LogTemplate
  attr_reader :time

  TIME_FORMAT_TEXT_ENTRY = "%m-%d-%Y %k:%M"

  def initialize(template_file_path)
    @time = Time.new.strftime(TIME_FORMAT_TEXT_ENTRY)
    @template_file_path = template_file_path
  end

  def build
    erb = ERB.new(File.read(@template_file_path))
    erb.result(get_binding)
  end

  # rubocop:disable
  def get_binding
    binding
  end
end
