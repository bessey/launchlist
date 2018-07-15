require "yaml"
require "checker/config/structures"

module Checker
  class Config
    class << self
      def parse_all(directory)
        files = Dir.glob(directory.path + "**/*.{yaml,yml}")
        files.map do |file|
          new(file).tap(&:parse)
        end
      end
    end
    extend Forwardable

    NotParsedError = Class.new(StandardError)

    attr_reader :path, :yaml, :errors
    def_delegators(:config, *Root.members)

    def initialize(path)
      @path = path
      @yaml = YAML.load_file(path)
    end

    def valid?
      !@errors || @errors.length.zero?
    end

    def config
      unless @config
        raise NotParsedError
      end
      @config
    end

    def parse
      @errors = JSON::Validator.fully_validate(Checker::Schema, @yaml)
      return false unless valid?
      @config = Root.new(
        @yaml["name"],
        @yaml["version"],
        parse_trigger_set(@yaml["triggers"]),
        parse_check_sets(@yaml["list"]),
      )
      assign_parents
      @config
    end

    def dup
      super
      @config = @config.dup
      assign_parents
      @config
    end

    def to_h
      {
        path: path,
        config: config,
        errors: errors
      }
    end

    private

    def assign_parents
      @config.list.each do |check_set|
        check_set.parent = @config
        check_set.checks.each do |check|
          check.parent = check_set
        end
      end
    end

    # To ensure we can tell the difference during active check build between a
    # trigger set that has had its triggers filtered, and one which was empty
    # from the start, we initialize TriggerSet to nil for the latter.
    def parse_trigger_set(trigger_set)
      return TriggerSet.new unless trigger_set
      paths = Array(trigger_set["paths"]).compact
      return TriggerSet.new unless paths
      TriggerSet.new(Set.new(paths))
    end

    def parse_check_sets(check_sets)
      return [] unless check_sets
      check_sets.map(&method(:parse_check_set))
    end

    def parse_check_set(check_set)
      if check_set.is_a?(String)
        CheckSet.new(
          nil,
          parse_checks([check_set]),
          parse_trigger_set(nil)
        )
      else
        CheckSet.new(
          check_set["category"],
          parse_checks(check_set["checks"]),
          parse_trigger_set(check_set["triggers"])
        )
      end
    end

    def parse_checks(checks)
      return [] unless checks
      checks.map(&method(:parse_check))
    end

    def parse_check(check)
      if check.is_a? String
        Check.new(check, parse_trigger_set(nil))
      else
        Check.new(
          check["check"],
          parse_trigger_set(check["triggers"])
        )
      end
    end
  end
end
