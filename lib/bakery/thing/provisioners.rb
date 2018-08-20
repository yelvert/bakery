module Bakery
  module Thing
    module Provisioners
      extend ActiveSupport::Autoload
      eager_autoload do
        autoload :Log
      end

      class Context
        attr_reader :thing_klass
        def initialize(thing_klass)
          @thing_klass = thing_klass
        end
      end

      def register(method, klass)
        base_klass = Bakery::Thing::Provisioner::Base
        raise "Only descendants of #{base_klass} may be registered as a Provisioner" unless klass < base_klass
        Context.send(:define_method, method) do |name = Time.now.to_s.gsub(/[^\d]/,'_'), *args, &block|
          thing_klass.provisioners.add(name, klass, *args, &block)
        end
      end
      module_function :register

    end
  end
end
