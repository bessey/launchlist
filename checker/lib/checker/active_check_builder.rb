module Checker
  class ActiveCheckBuilder
    attr_reader :config, :differ

    def initialize(config, differ)
      @config = config
      @differ = differ
    end

    # Create a copy of the given config, filtered to only include checks that
    # fired for the given diff, and with only the triggers that fired.
    def build
      config.dup.tap do |replacement|
        puts "FILTERING CONFIG"
        if replacement.triggers.any?
          replacement.triggers = process_triggers(replacement.triggers)
          if !replacement.triggers.any?
            replacement.list = []
            return replacement
          end
          replacement.list = filter_check_lists(replacement.list, replacement.triggers)
        else
          replacement.list = filter_check_lists(replacement.list)
        end
      end
    end

    private

    def filter_check_lists(list, triggers)
      list.map(&:dup).map do |check_list|
        puts "FILTERING CHECK LIST"
        old_checks = check_list.checks
        if check_list.triggers.any?
          check_list.triggers = process_triggers(
            check_list.triggers,
            triggers
          )
          # Remove check list from result if no triggers fired
          puts "FILTERING CHECKLIST TRIGGERS"
          next unless check_list.triggers.any?
          check_list.checks = filter_checks(old_checks, check_list.triggers, triggers)
        else
          check_list.checks = filter_checks(old_checks, check_list.triggers)
        end
        check_list
      end
    end

    def filter_checks(checks, *triggers)
      checks.map(&:dup).map do |check|
        puts "FILTERING CHECK"
        puts check
        if check.triggers.any?
          check.triggers = process_triggers(
            check.triggers,
            *triggers
          )
          # Remove check from result if no triggers fired
          next unless check.triggers.any?
        end
        check
      end
    end

    def process_triggers(*trigger_sets)
      paths = process_paths(*trigger_sets)
      Config::TriggerSet.new(paths)
    end

    def process_paths(*trigger_sets)
      trigger_sets.inject(differ.modified_paths) do |remaining_paths, set|
        remaining_paths.select do |path|
          set.paths.any? do |glob|
            glob_regex = Glob.new(glob).to_regexp
            path.match?(glob_regex)
          end
        end
      end
    end
  end
end
