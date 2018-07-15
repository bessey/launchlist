module Checker
  class Differ
    MissingSHAError = Class.new(ArgumentError)
    attr_reader :repo, :diff
    SHA_REGEX = /\A[a-f,0-9]{40}\Z/i

    def initialize(path_in_repo, base_target, head_target)
      @repo = Rugged::Repository.discover(path_in_repo)
      base = lookup_reference!(base_target)
      head = lookup_reference!(head_target)
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

    def lookup_reference!(reference)
      sha = target_to_sha(reference)
      confirm_sha_exists!(sha)
      repo.lookup(sha)
    end

    def target_to_sha(reference)
      case reference
      when "HEAD"
        repo.head.target_id
      when SHA_REGEX
        confirm_sha_exists!(reference)
        reference
      else
        branch = repo.branches[reference]
        raise MissingSHAError unless branch
        branch.target_id
      end
    end

    def confirm_sha_exists!(sha)
      unless repo.exists?(sha)
        raise MissingSHAError, "SHA #{sha} Not Found"
      end
    end
  end
end
