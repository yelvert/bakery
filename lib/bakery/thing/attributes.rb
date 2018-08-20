module Bakery
  module Thing
    module Attributes
      extend ActiveSupport::Concern

      included do
        class << self

          def attributes
            @_attributes ||= {}.with_indifferent_access
          end

          def attribute_names
            attributes.keys
          end

          def attribute(name, type)
            name = name.to_sym
            type = type.to_sym
            attributes[name] = type
            define_method(name) do
              instance_variable_get(:"@#{name}")
            end
            define_method(:"#{name}=") do |value|
              instance_variable_set(:"@#{name}", self.class.attribute_value_for_type(value, type))
            end
          end

          def attribute_value_for_type(value, type)
            m = :"attribute_value_for_type_#{type}"
            if respond_to? m
              send(m, value)
            else
              value
            end
          end

          def attribute_value_for_type_string(value)
            value.to_s
          rescue
            ''
          end

          def attribute_value_for_type_array(value)
            value.to_a
          rescue
            []
          end

        end

        def initialize(attrs = {})
          attrs = attrs.with_indifferent_access
          self.attribute_names.each do |name|
            send :"#{name}=", attrs[name]
          end
          super()
        end

        def attribute_names
          self.class.attribute_names
        end

        def attributes
          self.attribute_names.inject({}) do |memo, name|
            memo.merge(memo => send(name))
          end
        end

      end

    end
  end
end