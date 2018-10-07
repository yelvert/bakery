module Bakery
  module Thing
    extend ActiveSupport::Autoload
    autoload :Attributes
    autoload :Provisionable

    class Base

      include Attributes
      include Provisionable

      class << self
        attr_reader :aux_root
        def inherited(child_class)
          cm = caller[0].match /^(.*\/#{child_class.to_s.underscore}).rb:\d+:.*/
          if cm && cm[1]
            child_class.instance_variable_set :@aux_root, Pathname.new(cm[1])
          end
        end

        def aux_path_for(*path)
          aux_root.join(*path)
        end

      end

      delegate :aux_root, :aux_path_for, to: :class

    end
  end
end
