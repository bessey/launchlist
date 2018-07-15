require "thor"

module Checker
  class CLI < Thor
    desc "start", "calculate diff between two git SHAs and run against all checklists found"
    option :from, default: "master", type: :string
    option :to, default: "HEAD", type: :string
    option :lists, default: ".checklists/**/*.{yaml,yml}"
    long_desc <<~LONGDESC
      `checker run` will calculate the diff between (by default) the current branch HEAD and master
      HEAD, record which YAML check lists items apply to this diff, and upload the results to
      CheckLint.

      You may optionally override the from and to SHAs with --from SHA --to SHA.
      You may also override the path glob used to find all checklists.
    LONGDESC
    def start
      differ = Checker::Differ.new(Dir.pwd, options[:from], options[:to])
      checklist_files = Dir.glob(options[:lists])
      puts "Found #{checklist_files.length} lists in #{options[:lists]}"
      configs = parse_configs(checklist_files)
      outputs = build_results(configs)
      result_set = ResultSet.new(token, 1, outputs)
      upload(result_set)
    end

    private

    def parse_configs(checklist_files)
      checklist_files.map do |path|
        config = Checker::Config.new(path)
        unless config.parse
          puts "Error Passing #{path}"
          puts config.errors
          exit -1
        end
        config
      end
    end

    def build_results
      configs.map do |config|
        builder = Checker::ActiveCheckBuilder.new(config, differ)
        builder.build
      end
    end

    def upload
      exit_code = Uploader.new(result_set).upload ? 0 : 1
      exit exit_code
    end
  end
end
