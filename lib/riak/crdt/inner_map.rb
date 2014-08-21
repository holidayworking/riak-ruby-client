module Riak
  module Crdt
    # A map that exists inside a {TypedCollection} inside another map.
    class InnerMap
      attr_reader :counters, :flags, :maps, :registers, :sets

      attr_accessor :name

      # The parent of this counter.
      #
      # @api private
      attr_reader :parent

      # @api private
      def initialize(parent, value={})
        @parent = parent
        @value = value.symbolize_keys

        initialize_collections
      end

      # @api private
      def operate(inner_operation)
        wrapped_operation = Operation::Update.new.tap do |op|
          op.value = inner_operation
          op.type = :map
        end

        @parent.operate(name, wrapped_operation)
      end

      def pretty_print(pp)
        pp.object_group self do
          %w{counters flags maps registers sets}.each do |h|
            pp.comma_breakable
            pp.text "#{h}="
            pp.pp send h
          end
        end
      end

      # @api private
      def self.delete
        Operation::Delete.new.tap do |op|
          op.type = :map
        end
      end

      def context?
        @parent.context?
      end

      private
      def initialize_collections
        @counters = TypedCollection.new InnerCounter, self, @value[:counters]
        @flags = TypedCollection.new InnerFlag, self, @value[:flags]
        @maps = TypedCollection.new InnerMap, self, @value[:maps]
        @registers = TypedCollection.new InnerRegister, self, @value[:registers]
        @sets = TypedCollection.new InnerSet, self, @value[:sets]
      end
    end
  end
end
