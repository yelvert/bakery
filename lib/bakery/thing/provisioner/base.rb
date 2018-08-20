module Bakery
  module Thing
    module Provisioner
      class Base

        attr_reader :thing, :name, :args, :run_block

        def initialize(thing, name, *args, &block)
          @thing = thing
          @name = name
          @args = args
          @run_block = block
        end

        def run
          instance_eval(&run_block)
        end

      end

    end
  end
end
