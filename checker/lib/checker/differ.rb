module Checker
  class Differ
    MissingSHAError = Class.new(ArgumentError)
    attr_reader :repo, :diff

    def initialize(repo_path, base_sha, head_sha)
      @repo = Rugged::Repository.new(repo_path)
      confirm_shas_exist!(base_sha, head_sha)
      base = repo.lookup(base_sha)
      head = repo.lookup(head_sha)
      @diff = base.diff(head)
      diff.find_similar!
    end

    def modified_paths
      diff.each_delta.flat_map do |delta|
        [
          delta.old_file[:path],
          delta.new_file[:path]
        ].uniq
      end
    end

    private

    def confirm_shas_exist!(base_sha, head_sha)
      unless repo.exists?(base_sha)
        raise MissingSHAError, "Base SHA #{base_sha} Not Found"
      end
      unless repo.exists?(head_sha)
        raise MissingSHAError, "Head SHA #{base_sha} Not Found"
      end
    end
  end
end
