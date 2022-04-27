# frozen_string_literal: true

require_relative "version"
require_relative "repository"
require_relative "editor"
require "thor"

module Devlogs
  #
  # The CLI devlogs CLI
  #
  class CLI < Thor
    package_name "devlogs"

    # Returns exit with non zero status when an exception occurs
    def self.exit_on_failure?
      true
    end

    #
    # Returns version of the cli
    #
    desc "version", "Prints the current version"
    def version
      puts Devlogs::VERSION
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
        File.join(".", "_devlogs")
      )

      puts "Created devlogs"
    end

    #
    # Retrieves the most recent entry from the repository
    #
    desc "last", "Retrieves the last entry in the repository"
    method_options open: :boolean, alias: :string
    def last
      puts "Reading last entry"
      last_entry = repo.ls.first

      if options.open?
        Editor.open(last_entry)
      else
        puts File.read(last_entry)
      end
    end

    #
    # Synchronizes changes to mirrored repository
    #
    desc "sync_mirror", "Sync changes in devlogs repository to the configured mirror"
    def sync_mirror
      # TODO: repo.mirror_manager 
      #
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
