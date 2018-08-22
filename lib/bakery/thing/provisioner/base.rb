module Bakery
  module Thing
    module Provisioner
      class Base

        class << self

          def argument(name, options = {})
            name = name.to_sym || raise("Provisioner Argument name must be a string or symbol, but was: #{name}")
            raise("Provisioner Argument `#{name}` already exists") if arguments.member?(name)
            options = options.with_indifferent_access
            arguments[name] = options
            argument_order << name
            define_method(name) do |value = :__GETTER__|
              if value === :__GETTER__
                instance_variable_get :"@#{name}"
              else
                instance_variable_set :"@#{name}", value
              end
            end
          end

          def arguments ; @_arguments ||= {}.with_indifferent_access ; end

          def argument_order ; @_argument_order ||= [] ; end

          def argument_index(arg) ; @_argument_order.index(arg.to_sym) ; end

        end

        attr_reader :thing, :context, :name, :args, :run_block

        def initialize(thing, context, name, *args, &block)
          @thing = thing
          @context = context
          @name = name
          @args = args
          self.class.arguments.each do |arg, options|
            value = args[self.class.argument_index(arg)] || options[:default]
            send(arg, value)
          end
          instance_eval(&block) if block_given?
        end

        alias_method :provision, :context

        def run ; end

        def method_missing(method, *args, &block)
          if context.respond_to? method
            context.send(method, *args, &block)
          else
            super
          end
        end

      end

    end
  end
end
