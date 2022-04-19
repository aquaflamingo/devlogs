# frozen_string_literal: true

require_relative "devlog/version"
require_relative "devlog/repository"

require "thor"

module Devlog
  #
  # The CLI Devlog App
  #
  class App < Thor
    package_name "devlog"

    # Returns exit with non zero status when an exception occurs
    def self.exit_on_failure?
      true
    end

    #
    # Initializes a +devlog+ repository with a configuration
    #
    desc "init", "Initialize a developer logs for project"
    method_options force: :boolean, alias: :string
    def init
      puts "Creating devlog repository"

      Repository::Initialize.run(
        { force: options.force? },
        File.join(".", "__devlog")
      )

      puts "Created devlog"
    end

    #
    # Creates a devlog entry in the repository and syncs changes
    # to the mirrored directory if set
    #
    desc "entry", "Create a new devlog entry" # [4]
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
