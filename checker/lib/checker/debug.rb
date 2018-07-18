module Checker
  module Debug
    extend self
    def print_checklist(checklist)
      puts "### #{checklist.name || "Unnamed Checklist"} ###\n\n"

      checklist.list.each do |check_set|
        puts "#{check_set.category || "Unnamed Category"}"
        check_set.checks.each do |check|
          puts "- #{check.check}"
          if trigger = check.effective_trigger_set
            if trigger.paths
              puts "  (#{trigger.paths.length} paths)"
            else
              puts "  (always triggers)"
            end
          end
        end
        puts "\n"
      end
    end
  end
end
