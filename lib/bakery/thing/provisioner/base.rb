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

        attr_reader :thing, :name, :args, :run_block

        def initialize(thing, name, *args, &block)
          @thing = thing
          @name = name
          @args = args
          self.class.arguments.each do |arg, options|
            value = args[self.class.argument_index(arg)] || options[:default]
            send(arg, value)
          end
          @run_block = block
        end

        def execute_run_block
          instance_eval(&run_block) if run_block.present?
        end

        def run
          execute_run_block
          after_run
          self
        end

        def after_run ; end

      end

    end
  end
end
