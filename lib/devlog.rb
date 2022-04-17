# frozen_string_literal: true

require_relative "devlog/version"
require_relative "devlog/repository"

require 'thor'

module Devlog
  class App < Thor                                                 # [1]
    package_name "devlog"                                             # [2]

    def self.exit_on_failure?
      true
    end
    
    desc "init", "Initialize a developer logs for project"
    method_options :force => :boolean, :alias => :string  
    def init
      puts "Creating devlog repository"

      Repository::Initialize.run(
        {force: options.force?},
        File.join(".", "__devlog")
      )

      puts "Created devlog"
    end

    desc "entry", "Create a new devlog entry"   # [4]
    def entry
      puts "Creating new entry..."
      repo.create

      repo.sync
    end

    private
    def repo
      @repo ||= Repository.load
    end
  end
end
