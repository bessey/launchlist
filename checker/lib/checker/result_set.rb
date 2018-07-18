module Checker
  class ResultSet < Struct.new(:token, :version, :results)
    def print_debug_info
      results.each do |result|
        Debug.print_checklist(result)
      end
    end
  end
end
