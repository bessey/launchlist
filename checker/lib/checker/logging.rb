require "logger"

module Checker
  module Logging
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def logger
        @logger ||= begin
          l = Logger.new(STDOUT)
          l.level = Logger::INFO
          l.formatter = proc do |severity, datetime, progname, msg|
            "#{msg}\n"
          end
          l
        end
      end
    end

    def logger
      self.class.logger
    end
  end
end
