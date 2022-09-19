# frozen_string_literal: true

require_relative "erb_template_renderer"

#
# IssueTemplateRenderer captures issue information and
# renders it within a given ERB template
#
class IssueTemplateRenderer < ErbTemplateRenderer
  attr_reader :title, :description, :reproduction

  def initialize(template_file_path, info = {})
    super(template_file_path)

    @title = info[:display_title]
    @description = info[:description]
    @reproduction = info[:reproduction]
  end
end
