module Bakery
  module Thing
    module Provisioner
      extend ActiveSupport::Autoload
      autoload :Base
      autoload :Context

      # Built-in provisioners
      eager_autoload do
        autoload :Download, 'bakery/thing/provisioners/download'
        autoload :Log, 'bakery/thing/provisioners/log'
        autoload :Shell, 'bakery/thing/provisioners/shell'
        autoload :Vagrant, 'bakery/thing/provisioners/vagrant'
      end

      def register(method, klass)
        base_klass = Bakery::Thing::Provisioner::Base
        raise "Only descendants of #{base_klass} may be registered as a Provisioner" unless klass < base_klass
        Context.send(:define_method, method) do |**args, &block|
          provision(klass, thing, **args, &block)
        end
      end
      module_function :register
    end
  end
end
