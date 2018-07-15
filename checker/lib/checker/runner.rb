module Checker
  class Runner
    include Logging
    # Main checker API
    # Returns true if sucessfull, false otherwise
    def run(from, to, token:, lists:, skip_upload: false)
      checklist_files = Dir.glob(lists)
      logger.info "Found #{checklist_files.length} lists in #{lists}"
      configs = parse_configs(checklist_files)
      return false unless configs
      outputs = build_results(from, to, configs)
      result_set = ResultSet.new(token, 1, outputs)
      upload(result_set, skip_upload)
    end

    private

    def parse_configs(checklist_files)
      checklist_files.map do |path|
        config = Config.new(path)
        unless config.parse
          logger.error "Error Passing #{path}\n#{config.errors}"
          return false
        end
        config
      end
    end

    def build_results(from, to, configs)
      logger.info "Building results for files in diff #{from[0...8]}..#{to[0...8]}"
      differ = Differ.new(Dir.pwd, from, to)
      configs.map do |config|
        builder = ActiveCheckBuilder.new(config, differ)
        builder.build
      end
    end

    def upload(result_set, skip)
      skip || Uploader.new(result_set).upload
    end
  end
end
