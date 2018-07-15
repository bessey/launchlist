module Checker
  class Serializer
    attr_reader :config

    def initialize(root)
      @config = root
    end

    def to_json_payload
      config
    end
  end
end
