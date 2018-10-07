module Bakery
  module Thing
    module Provisioner
      class Context
        attr_reader :thing, :description
        def initialize(thing, description, &block)
          @thing = thing
          @description = description
          yield(self, thing)
        end

        def provisioner_chain
          @provisioner_chain ||= []
        end

        def provision(klass, thing, **args, &block)
          provisioner = klass.new(thing, self, **args)
          provisioner_chain << provisioner
          provisioner.execute(&block)
          provisioner.run
          provisioner_chain.pop
          provisioner
        end

        def current_provisioner
          provisioner_chain.last
        end

        def parent_provisioner
          provisioner_chain[-2]
        end

      end
    end
  end
end
