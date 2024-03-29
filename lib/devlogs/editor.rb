# frozen_string_literal: true

require_relative "./executable.rb"

# Wrapper for terminal editor
class Editor < Executable
  def initialize
    @program = ENV["EDITOR"]
  end

  # Opens the file contained at the path
  def open(path)
    command = "#{@program} #{path}"

    system command
  end

  class << self
    # Opens the file at +path+ using system editor
    def open(path)
      session = new

      session.open(path)
    end
  end
end
