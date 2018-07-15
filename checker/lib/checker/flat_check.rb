module Checker
  class FlatCheck
    class << self
      def flatten_config(config)
        config.list.flat_map do |check_set|
          check_set.map do |check|
            new(check, check_set, config)
          end
        end
      end
    end

    attr_reader :check, :check_set, :root_config

    def initialize(check, check_set, root_config)
      @check = check
      @check_set = check_set
      @root_config = root_config
    end

    def trigger_sequence
      [root_config, check_set, check]
    end

    def triggers
      # paths = combine_all(check.triggers.paths +
      #   check_set.triggers.paths +
      #   root_config.triggers.paths
      Config::TriggerSet.new(paths)
    end

    private

    def combine_all(trigger_type, combinable)
      combinable.inject(Set.new) do |acc, item|
        acc & item.triggers.public_send(trigger_type)
      end
    end

    def combinable
      [check, check_set, root_config]
    end
  end
end
