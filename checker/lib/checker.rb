require "rugged"
require "json-schema"
require "checker/logging"
require "checker/active_check_builder"
require "checker/cli"
require "checker/config"
require "checker/differ"
require "checker/glob"
require "checker/result_set"
require "checker/runner"
require "checker/schema"
require "checker/uploader"
require "checker/version"

module Checker
  extend self

  def run(from, to, token:, lists:, skip_upload: false)
    Runner.new.run(from, to, token: token, lists: lists, skip_upload: skip_upload)
  end
end
