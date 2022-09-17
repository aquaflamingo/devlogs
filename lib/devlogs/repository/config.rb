# frozen_string_literal: true

# The repository's configuration values located in the yml file
class Repository
  class Config
    # FIXME: Need to figure out file path
    attr_reader :name, :description, :mirror, :file_path, :template_file_path

    # Configuration associated with the Mirror
    MirrorConfig = Struct.new(:use_mirror, :path, keyword_init: true)

    def initialize(path, opts = {})
      @file_path = path
      @template_file_path = opts[:template_file_path]
      @name = opts[:name]
      @description = opts[:description]
      @mirror = MirrorConfig.new(opts[:mirror])
    end

    # Returns whether or not the devlogs repository is configured to mirror
    #
    # @returns [Boolean]
    def mirror?
      @mirror.use_mirror
    end

    # Ensures no weird double trailing slash path values
    def path(with_trailing: false)
      if with_trailing
        @file_path[-1] == "/" ? @path_value : @path_value + "/"
      else
        @file_path
      end
    end
  end
end
