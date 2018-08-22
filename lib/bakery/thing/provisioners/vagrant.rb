module Bakery
  module Thing
    module Provisioner
      extend ActiveSupport::Autoload
      autoload :Base

      class Vagrant < Base
        argument :directory

        def run
          provision.log(:vagrant_test, directory)
        end

      end
      register :vagrant, Vagrant

    end
  end
end
