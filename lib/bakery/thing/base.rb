module Bakery
  module Thing
    extend ActiveSupport::Autoload
    autoload :Attributes
    autoload :Provisionable

    class Base

      include Attributes
      include Provisionable

    end
  end
end
