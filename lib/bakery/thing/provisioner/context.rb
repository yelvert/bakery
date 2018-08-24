module Bakery
  module Thing
    module Provisioner
      class Context
        attr_reader :thing, :description
        def initialize(thing, description, &block)
          @thing = thing
          @description = description
          instance_eval &block
        end

        def provisioners
          @provisioners ||= {}
        end

        def provisioner_chain
          @provisioner_chain ||= []
        end

        def provision(klass, thing, name = nil, *args, &block)
          name ||= SecureRandom.uuid
          raise "Provisioner named #{name} already exists." if provisioners.member? name
          provisioner = klass.new(thing, self, name, *args)
          provisioners[name] = provisioner
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
          provisioner_chian[-2]
        end

      end
    end
  end
end
