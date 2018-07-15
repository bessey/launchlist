require "thor"

module Checker
  class CLI < Thor
    desc "run", "calculate diff between two git SHAs and run against all checklists found"
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
    def run(name)
      puts "Hello #{name}"
    end
  end
end
