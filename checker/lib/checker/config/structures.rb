module Checker
  class Config
    module Triggerable
      def dup
        super().tap do |me|
          me.triggers = me.triggers.dup
        end
      end
    end

    module Parentable
      attr_accessor :parent
      def flattened_triggers
        [*parent.flattened_triggers, triggers]
      end

      # If a check fires, only the deepest trigger set is responsible for it
      def effective_trigger_set
        flattened_triggers.last
      end
    end

    module NestedCheckable
      def dup
        super().tap do |me|
          me.children = me.children.map(&:dup)
        end
      end
    end

    Root = Struct.new(:name, :version, :triggers, :list) do
      include Triggerable
      include NestedCheckable
      def children
        list
      end
      def children=(children)
        self.list = children
      end
      def flattened_triggers
        [triggers]
      end
    end

    CheckSet = Struct.new(:category, :checks, :triggers) do
      include Parentable
      include Triggerable
      include NestedCheckable
      def children
        checks
      end
      def children=(children)
        self.checks = children
      end
    end

    Check = Struct.new(:check, :triggers) do
      include Parentable
      include Triggerable
    end

    TriggerSet = Struct.new(:paths) do
      def active?
        !!paths
      end
      def any?
        paths.length > 0
      end
    end
  end
end
