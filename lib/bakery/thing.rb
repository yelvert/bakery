module Bakery
  module Thing
    extend ActiveSupport::Autoload
    autoload :Base

    Bakery::Thing::Provisioners.eager_load!

  end
end
