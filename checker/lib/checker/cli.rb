require "thor"

module Checker
  class CLI < Thor
    desc "start", "calculate and upload checklist results for the working directory repository"
    option :token, type: :string, required: true, desc: "Your authentication token, specific to the repo"
    option :from, default: "master", type: :string, desc: "The base commit / reference from which to compare"
    option :to, default: "HEAD", type: :string, desc: "The head commit / reference with which to compare"
    option :lists, default: ".checklists/**/*.{yaml,yml}", desc: "The path glob used to find all checklists"
    option :skip_upload, default: false, type: :boolean
    long_desc <<~LONGDESC
      `checker run --token TOKEN` will calculate the diff between (by default) the current branch
      HEAD and master HEAD, record which YAML check lists items apply to this diff, and upload
      the results to CheckLint, associating them with the repo of the given TOKEN.
    LONGDESC
    def start
      if Checker.run(
          options[:from],
          options[:to],
          lists: options[:lists],
          token: options[:token],
          skip_upload: options[:skip_upload]
        )
        exit 0
      else
        exit -1
      end
    end
  end
end
