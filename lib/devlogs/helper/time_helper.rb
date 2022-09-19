# frozen_string_literal: true

module TimeHelper
  # Example: 11-22-2022__13h43m
  TIME_FORMAT_FILE_PREFIX = "%m-%d-%Y__%kh%Mm"

  def current_time(format: TIME_FORMAT_FILE_PREFIX)
    time = Time.new
    time.strftime(format)
  end
end
