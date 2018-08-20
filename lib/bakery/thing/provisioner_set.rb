module Bakery
  module Thing
    extend ActiveSupport::Autoload
    autoload :Provisioner
    autoload :Provisioners

    class ProvisionerSet

      class ProvisionerSetItem
        attr_reader :name, :klass, :args, :run_block
        def initialize(name, klass, *args, &block)
          @name = name
          @klass = klass
          @args = @args
          @run_block = block
        end

        def run(thing)
          provisioner = klass.new(thing, name, *args, &run_block)
          provisioner.run
          provisioner
        end
      end

      attr_reader :done, :thing_klass

      def initialize(thing_klass)
        @_provisioners = []
        @provisioners = []
        @done = true
        @thing_klass = thing_klass
      end

      def all
        @_provisioners.dup.freeze
      end

      def create(name, klass, *args, &block)
        raise "Provisioner needed to be a Bakery::Thing::Provisioner::Base, but was a #{klass}" unless klass < Bakery::Thing::Provisioner::Base
        ProvisionerSetItem.new(name, klass, *args, &block)
      end

      def add(*args, &block)
        @_provisioners << create(*args, &block)
      end

      def remove(name)
        @_provisioners.delete(lookup(name))
      end

      def insert_before(before, *args, &block)
        before_index = @_provisioners.index_of(lookup(before))
        provisioner = create(*args, block)
        @_provisioners.insert(before_index, provisioner)
      end

      def insert_after(after, *args, &block)
        after_index = @_provisioners.index_of(lookup(after)) + 1
        provisioner = create(*args, block)
        @_provisioners.insert(after_index, provisioner)
      end

      def lookup(name)
        name = name.name if name.is_a?(ProvisionerSetItem)
        @_provisioners.find {|b| b.name === name } || raise("Cannot find Provisioner named: #{name}")
      end

      def run(thing)
        @_provisioners.map {|psi| psi.run(thing) }
      end

      def provision_context
        @provision_conext ||= Provisioners::Context.new(thing_klass)
      end

    end
  end
end
