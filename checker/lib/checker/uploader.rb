require "http"

module Checker
  class Uploader
    DEFAULT_ENDPOINT = 'https://checklint.com/api/check_lists'
    def initialize(results)
      @results = results
    end

    def upload
      response = HTTP.post(endpoint, json: serialize_value(@results))
      case response.code
      when 200, 201
        puts "Upload successful!"
        true
      else
        puts "Error Uploading: HTTP Status #{response.code}"
        puts response.body.to_s
        false
      end
    end

    private

    def serialize_value(value)
      case value
      when Array
        value.map(&method(:serialize_value))
      when Hash
        value.transform_values!(&method(:serialize_value))
      when Set
        serialize_value(value.to_a)
      when Struct, Config
        serialize_value(value.to_h)
      else
        value
      end
    end

    def endpoint
      ENV["CHECKER_CHECKLIST_ENDPOINT"] || DEFAULT_ENDPOINT
    end
  end
end
