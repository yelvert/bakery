module Bakery
  module Thing
    module Provisioner
      class Base

        class << self

          def argument(name, type = :default, options = {})
            name = name.to_sym || raise("Provisioner Argument name must be a string or symbol, but was: #{name}")
            arguments.member?(name) && raise("Provisioner Argument `#{name}` already exists")
            argument_types.include?(type) || raise("Provisioner Argument type `#{type}` is not a valid. Options are #{argument_types.join(', ')}.")
            options = options.with_indifferent_access
            options[:type] = type
            arguments[name] = options
            argument_order << name
            alias_method name, :"__argument_#{type}"
          end

          def arguments ; @_arguments ||= {}.with_indifferent_access ; end

          def argument_order ; @_argument_order ||= [] ; end

          def argument_index(arg) ; @_argument_order.index(arg.to_sym) ; end

          def argument_types
            instance_methods.
              inject([]) do |memo, method|
                memo << method.to_s.sub(/^__argument_/, '').to_sym if method.to_s.starts_with? '__argument_'
                memo
              end.
              without(:default)
          end

        end

        attr_reader :thing, :context, :name, :args, :run_block

        delegate :provisioner_chain, :parent_provisioner, to: :context

        def initialize(thing, context, name, *args)
          @thing = thing
          @context = context
          @name = name
          @args = args
          self.class.arguments.each do |arg, options|
            value = options[:default]
            arg_index = self.class.argument_index(arg)
            value = args[arg_index] if args.size > arg_index
            raise "Provisioner `#{self.class.class_name
            }` Argument `#{arg}` may not be nil" if value.nil? || options[:allow_nil]
            send(arg, value)
          end
        end

        def execute(&block)
          instance_eval(&block) if block_given?
        end

        def run ; end

        def __argument_default(value = getter = true)
          name = __callee__
          if getter
            instance_variable_get :"@#{name}"
          else
            instance_variable_set :"@#{name}", value
          end
        end

        def __argument_string(value = getter = true)
          name = __callee__
          if getter
            instance_variable_get :"@#{name}"
          else
            if value.respond_to?(:to_s)
              instance_variable_set :"@#{name}", value.to_s
            else
              raise "Provided value for Provisioner `#{self.class.class_name}`'s argument `#{name}` must be coercable to a String"
            end
          end
        end

        def __argument_symbol(value = getter = true)
          name = __callee__
          if getter
            instance_variable_get :"@#{name}"
          else
            if value.respond_to?(:to_sym)
              instance_variable_set :"@#{name}", value.to_sym
            else
              raise "Provided value for Provisioner `#{self.class.class_name}`'s argument `#{name}` must be coercable to a Symbol"
            end
          end
        end

        def __argument_array(value = getter = true)
          name = __callee__
          if getter
            instance_variable_get :"@#{name}"
          else
            if value.is_a?(Array)
              instance_variable_set :"@#{name}", value
            else
              raise "Provided value for Provisioner `#{self.class.class_name}`'s argument `#{name}` must be an Array"
            end
          end
        end

        def __argument_hash(value = getter = true)
          name = __callee__
          if getter
            instance_variable_get :"@#{name}"
          else
            if value.is_a?(Hash)
              instance_variable_set :"@#{name}", value
            else
              raise "Provided value for Provisioner `#{self.class.class_name}`'s argument `#{name}` must be a Hash"
            end
          end
        end

        def __argument_path(value = getter = true)
          name = __callee__
          if getter
            instance_variable_get :"@#{name}"
          else
            begin
              value = Pathname.new(value)
            rescue
              raise "Provided value for Provisioner `#{self.class.class_name}`'s argument `#{name}` must be a Path"
            end
            instance_variable_set :"@#{name}", value
          end
        end

        def __argument_block(value = getter = true, &block)
          name = __callee__
          if getter && !block_given?
            instance_variable_get :"@#{name}"
          else
            if block_given?
              instance_variable_set :"@#{name}", block
            elsif value.is_a? Proc
              instance_variable_set :"@#{name}", value
            else
              raise "Provided value for Provisioner `#{self.class.class_name}`'s argument `#{name}` must be a Proc, lambda, or block"
            end
          end
        end

      end

    end
  end
end
