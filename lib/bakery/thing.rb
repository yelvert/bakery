module Bakery
  module Thing
    extend ActiveSupport::Autoload
    autoload :Base

    Bakery::Thing::Provisioner.eager_load!

  end
end
