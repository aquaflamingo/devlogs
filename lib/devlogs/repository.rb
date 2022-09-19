# frozen_string_literal: true

require "fileutils"
require "tty-prompt"
require "pry"
require "time"

require_relative "repository/config_store"
require_relative "editor"
require_relative "repository/sync_manager"
require_relative "helper/time_helper"
require_relative "repository/log_manager"
require_relative "repository/issue_manager"

# Repository is an accessor object for the devlogs directory
class Repository
  include TimeHelper

  # Initializes a .devlogs repository with the supplied configuration
  #
  def initialize(repo_config_store)
    @config_store = repo_config_store
    @repo_config = @config_store.values
  end

  # Creates a new .devlogs entry for recording session completion
  #
  # @returns nil
  def create
    entry_file_path = log_manager.create_entry 

    Editor.open(entry_file_path)

    puts "Writing entry to #{entry_file_path}.."
  end

  #
  # @returns nil
  def create_issue
    issue_file_path = issue_manager.create

    Editor.open(issue_file_path)

    puts "Writing issue to #{issue_file_path}.."
  end

  # Syncs the directory changes to the (optional) mirror repository
  # specified in the configuration.
  #
  # @returns nil
  def sync
    sync_manager.run if @repo_config.mirror?
  end

  # Lists the files in the repository
  def ls(direction = :desc)
    log_manager.list_entries(direction)
  end

  class << self
    # Loads a repository from the provided path
    #
    # @returns [Repository]
    #
    def load(path = File.join(Repository::ConfigStore::DEFAULT_DIRECTORY_PATH, Repository::ConfigStore::DEFAULT_DIRECTORY_NAME))
      store = Repository::ConfigStore.load_from(path)

      new(store)
    end
  end

  private

  def sync_manager
    @sync_manager ||= Repository::SyncManager.new(@config_store)
  end

  def log_manager
    @log_manager ||= LogManager.new(@config_store)
  end

  def issue_manager
    @issue_manager ||= IssueManager.new(@config_store)
  end
end
