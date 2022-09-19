# frozen_string_literal: true

require_relative "version"
require_relative "repository"
require_relative "editor"
require_relative "pager"
require_relative "helper/tty_prompt_helper"
require_relative "repository/initializer"
require "thor"

module Devlogs
  #
  # The CLI devlogs CLI
  #
  class CLI < Thor
    include TTYPromptHelper

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
    method_options force: :boolean
    method_options dirpath: :string
    def init
      puts "Creating devlogs repository"

      Repository::Initializer.run(
        { 
          force: options.force?,
          dirpath: options.dirpath,
        },
      )

      puts "Created devlogs repository"
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

    # FIXME: Add logs sub command
    #
    # Creates a devlogs entry in the repository and syncs changes
    # to the mirrored directory if set
    #
    desc "new", "Create a new devlogs entry" # [4]
    def new
      puts "Creating new entry..."
      repo.create

      repo.sync
    end

    # FIXME: Add logs sub command
    #
    # Creates a devlogs entry in the repository and syncs changes
    # to the mirrored directory if set
    #
    desc "new_issue", "Create a new devlogs entry" # [4]
    def new_issue
      repo.create_issue
      repo.sync
    end

    #
    # Lists repository logs
    #
    desc "ls", "Lists the repository logs and allows you to select"
    def ls
      entries = repo.ls

      if entries.size < 1 
        puts "No logs present in this repository"
        exit 0
      end

      # Use the file names as visible keys for the prompt
      entry_names = entries.map { |e| File.basename(e) }

      # Build the TTY:Prompt
      result = build_select_prompt(data: entry_names, text: "Select a log entry...")

      # Open in paging program
      Pager.open(entries[result])
    end

    private

    # Helper method for repository loading
    #
    def repo
      # FIXME: Need to add in path specification here 
      @repo ||= Repository.load
    end
  end
end
