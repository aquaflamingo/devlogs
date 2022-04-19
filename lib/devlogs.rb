# frozen_string_literal: true

require_relative "devlogs/version"
require_relative "devlogs/repository"

require "thor"

module Devlogs
  #
  # The CLI devlogs App
  #
  class App < Thor
    package_name "devlogs"

    # Returns exit with non zero status when an exception occurs
    def self.exit_on_failure?
      true
    end

    #
    # Initializes a +devlogs+ repository with a configuration
    #
    desc "init", "Initialize a developer logs for project"
    method_options force: :boolean, alias: :string
    def init
      puts "Creating devlogs repository"

      Repository::Initialize.run(
        { force: options.force? },
        File.join(".", "__devlogs")
      )

      puts "Created devlogs"
    end

    #
    # Creates a devlogs entry in the repository and syncs changes
    # to the mirrored directory if set
    #
    desc "entry", "Create a new devlogs entry" # [4]
    def entry
      puts "Creating new entry..."
      repo.create

      repo.sync
    end

    private

    # Helper method for repository loading
    #
    def repo
      @repo ||= Repository.load
    end
  end
end