# frozen_string_literal: true

require_relative "config_store"

# Initialize is an execution object which initializes a Repository on the
# filesystem
class Repository
  class Initializer
    # Creates a new devlogs repository at the provided path
    def self.run(opts = {})
      new_config = ConfigBuilder.new(opts[:dirpath])

      draft = new_config.build

      draft.save!(force: opts[:force])
    end
  end
end
