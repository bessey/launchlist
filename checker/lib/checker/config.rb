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

    Config = Struct.new(:name, :version, :list, :triggers)
    CheckSet = Struct.new(:category, :checks)
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
      return unless valid?
      @config = Config.new(
        name: @yaml["name"],
        version: @yaml["version"],
        triggers: parse_trigger_set(@yaml["triggers"]),
        check_sets: parse_check_sets(@yaml["list"]),
      )
    end

    private

    def parse_trigger_set(trigger_set)
      return TriggerSet.new([]) unless trigger_set
    end

    def parse_check_sets(check_sets)
      return [] unless check_sets
    end

    def parse_check_set(check_set)
    end

    def parse_check(check)
    end
  end
end
