# frozen_string_literal: true

require "rsync"

# FIXME: Create module
class Repository
  #
  # SyncManager is an abstraction class for managing any necessity to sync
  # files on the file system using Rsync.
  #
  class SyncManager
    #
    # @param config_store [Repository::ConfigStore]
    #
    def initialize(config_store)
      @config_store = config_store
    end

    # Run rsync with -a to copy directories recursively

    # Use trailing slash to avoid sub-directory
    # See rsync manual page
    #
    # @throws Error if sync fails
    def run
      dest_path = @config_store.values.mirror.path
      src_path = config_store_path_with_trailing

      runner.run("-av", src_path, dest_path) do |result|
        if result.success?
          puts "Mirror sync complete."
          result.changes.each do |change|
            puts "#{change.filename} (#{change.summary})"
          end
        else
          raise "Failed to sync: #{result.error}"
        end
      end
    end

    private

    #
    # Utility method for getting access to the runner program
    # @returns [Rsync]
    #
    def runner
      @runner ||= Rsync
    end

    # Depending on the runner (Rsync) program,
    # you may need a trailing slash on the directory path
    #
    # @returns [String]
    def config_store_path_with_trailing
      @config_store.dir[-1] == "/" ? @config_store.dir : @config_store.dir + "/"
    end
  end
end
