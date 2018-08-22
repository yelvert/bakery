module Bakery
  module Thing
    extend ActiveSupport::Autoload
    autoload :Provisioner

    module Provisionable
      extend ActiveSupport::Concern

      included do

        class << self

          def provision(description = SecureRandom.uuid, &block)
            raise "Provisioner `#{description}` already exists for #{self}." if provision_blocks.member? description
            provision_blocks[description] = block
          end

          def provision_blocks
            @provision_blocks ||= {}
          end

        end

        def provision
          @provision ||= self.class.provision_blocks.inject({}) do |memo, pair|
            description, block = pair
            memo.merge! description => Provisioner::Context.new(self, description, &block)
          end
        end

      end

    end
  end
end
