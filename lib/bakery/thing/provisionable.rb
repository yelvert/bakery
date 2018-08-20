module Bakery
  module Thing
    extend ActiveSupport::Autoload
    autoload :ProvisionerSet
    eager_autoload do
      autoload :Provisioners
    end

    module Provisionable
      extend ActiveSupport::Concern

      included do

        class << self

          def provisioners
            @provisioners ||= ProvisionerSet.new(self)
          end

          def provision(&block)
            provisioners.provision_context.instance_eval &block
          end

        end

        def provision
          @provisioners ||= self.class.provisioners.run(self)
        end

        def provisioned?
          @provisioners.present?
        end

      end

    end
  end
end
