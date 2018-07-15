module Checker
  class ActiveCheckBuilder
    attr_reader :config, :differ

    def initialize(root, differ)
      @config = root
      @differ = differ
    end

    # Create a copy of the given config, filtered to only include checks that
    # fired for the given diff, and with only the triggers that fired.
    def build
      config.dup.tap do |replacement|
        # Process every checklist's checks triggers, removing ones which didn't fire
        replacement.list.each do |check_list|
          check_list.checks.each do |check|
            filter_triggers!(check)
          end
          # Process every checklist's checks, removing ones with no triggers
          filter_untriggered_checks!(check_list)
        end
        # Process every checklist, removing ones with no fired triggers
        filter_untriggered_check_lists!(replacement)
        # Process every checklist, removing ones with no remaining checks
        filter_checkless_check_lists!(replacement)
      end
    end

    private

    def filter_triggers!(check)
      changed_paths = differ.modified_paths
      check.flattened_triggers.inject(changed_paths) do |remaining_paths, trigger_set|
        # Pass through all if no filters
        next remaining_paths if !trigger_set.paths
        # Filter the trigger's paths to those which have 1+ matches
        next_remaining_paths = []
        trigger_set.paths.each do |glob|
          glob_regex = Glob.new(glob).to_regexp
          # Filter the changed paths to those which have 1+ triggers
          next_remaining_paths += remaining_paths.select do |changed_file|
            changed_file.match?(glob_regex)
          end
        end
        trigger_set.paths = next_remaining_paths.sort.uniq
      end
    end

    def filter_untriggered_checks!(check_list)
      check_list.checks = check_list.checks.select do |check|
        !check.triggers.active? || check.triggers.active? && check.triggers.any?
      end
    end

    def filter_untriggered_check_lists!(config)
      config.list = config.list.select do |check_list|
        !check_list.triggers.active? ||
          check_list.triggers.active? && check_list.triggers.any?
      end
    end

    def filter_checkless_check_lists!(config)
      config.list = config.list.reject do |check_list|
        check_list.checks.length.zero?
      end
    end
  end
end
