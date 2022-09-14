# frozen_string_literal: true

# Wrapper for terminal reader
require_relative './executable.rb'

# Wrapper for terminal pager
class Pager < Executable
  def initialize
    @program = ENV["PAGER"]
  end
end
