require "http"

module Checker
  class Uploader
    include Logging
    DEFAULT_ENDPOINT = 'https://launchlist.com/api/check_lists'
    def initialize(results)
      @results = results
    end

    def upload
      logger.info "Beginning upload of results..."
      response = HTTP.timeout(:per_operation, write: 10, connect: 10, read: 10)
        .post(endpoint, json: serialize_value(@results))
      case response.code
      when 200, 201
        logger.info "Upload successful!"
        true
      else
        logger.error "Error Uploading: HTTP Status #{response.code}\n#{response.body}"
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
