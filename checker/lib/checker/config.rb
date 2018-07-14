require "yaml"

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

    Config = Struct.new(:name, :version, :triggers, :list)
    CheckSet = Struct.new(:category, :checks, :triggers)
    TriggerSet = Struct.new(:paths)
    Check = Struct.new(:check, :triggers)

    attr_reader :path, :yaml, :errors, :config

    def initialize(path)
      @path = path
      @yaml = YAML.load_file(path)
    end

    def valid?
      !@errors || @errors.length.zero?
    end

    def parse
      @errors = JSON::Validator.fully_validate(Checker::Schema, @yaml)
      return false unless valid?
      @config = Config.new(
        @yaml["name"],
        @yaml["version"],
        parse_trigger_set(@yaml["triggers"]),
        parse_check_sets(@yaml["list"]),
      )
    end

    private

    def parse_trigger_set(trigger_set)
      return TriggerSet.new([]) unless trigger_set
      TriggerSet.new(
        Array(trigger_set["paths"]).compact
      )
    end

    def parse_check_sets(check_sets)
      return [] unless check_sets
      check_sets.map(&method(:parse_check_set))
    end

    def parse_check_set(check_set)
      CheckSet.new(
        check_set["category"],
        parse_checks(check_set["checks"]),
        parse_trigger_set(check_set["triggers"])
      )
    end

    def parse_checks(checks)
      return [] unless checks
      checks.map(&method(:parse_check))
    end

    def parse_check(check)
      if check.is_a? String
        Check.new(check)
      else
        Check.new(
          check["check"],
          parse_trigger_set(check["triggers"])
        )
      end
    end
  end
end
