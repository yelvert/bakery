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

      end
    end
  end
end
