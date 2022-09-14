# frozen_string_literal: true

class Executable
  def initialize
    raise NotImplementedError, "Abstract class"
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
