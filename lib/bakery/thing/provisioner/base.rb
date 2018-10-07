module Bakery
  module Thing
    module Provisioner
      class Base

        class << self

          def argument(name, type = :default, options = {}, &block)
            name = name.to_sym || raise("Provisioner Argument name must be a string or symbol, but was: #{name}")
            arguments.member?(name) && raise("Provisioner Argument `#{name}` already exists")
            argument_types.include?(type) || raise("Provisioner Argument type `#{type}` is not a valid. Options are #{argument_types.join(', ')}.")
            options = options.with_indifferent_access
            options[:type] = type
            options[:default] = block if block_given?
            arguments[name] = options
            alias_method name, "__argument_#{type}"
            alias_method "#{name}?", "__argument_#{type}?" if type == :boolean
          end

          def arguments ; @_arguments ||= {}.with_indifferent_access ; end

          def inherited(child_class)
            child_class.arguments.reverse_merge!(arguments)
          end

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

        def initialize(thing, context, **args)
          @thing = thing
          @context = context
          @name = name
          args = args.with_indifferent_access
          @args = args
          self.class.arguments.each do |arg, options|
            value = if args.member? arg
              args[arg]
            elsif options[:default].is_a? Proc
              instance_exec &options[:default]
            end
            send(arg, value) unless value.nil?
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

        def __argument_integer(value = getter = true)
          name = __callee__
          if getter
            instance_variable_get :"@#{name}"
          else
            begin
              instance_variable_set :"@#{name}", Integer(value)
            rescue TypeError
              raise "Provided value for Provisioner `#{self.class.class_name}`'s argument `#{name}` must be coercable to an Integer"
            end
          end
        end

        def __argument_boolean(value = getter = true)
          name = __callee__
          if getter
            !!instance_variable_get(:"@#{name}")
          else
            instance_variable_set :"@#{name}", !!value
          end
        end

        def __argument_boolean?
          name = __callee__.to_s.sub(/\?$/, '')
          !!send(name)
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
              options = self.class.arguments[name]
              value = value.expand_path if options[:expand]
            rescue
              raise "Provided value for Provisioner `#{self.class.class_name}`'s argument `#{name}` must be a Path"
            end
            instance_variable_set :"@#{name}", value
          end
        end

        def __argument_uri(value = getter = true)
          name = __callee__
          if getter
            instance_variable_get :"@#{name}"
          else
            begin
              value = URI.parse(value)
              options = self.class.arguments[name]
              if options[:valid_schemes].is_a?(Array) && !options[:valid_schemes].include?(value.scheme)
                raise "Provided URI scheme for Provisioner `#{self.class.class_name}`'s argument `#{name}` must be one of: #{options[:valid_schemes].inspect} but was #{value.scheme.inspect}"
              end
              instance_variable_set :"@#{name}", value
            rescue URI::InvalidURIError => err
              raise "Provided value for Provisioner `#{self.class.class_name}`'s argument `#{name}` must be a URI"
            end
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

        argument(:name, :string) { SecureRandom.uuid }

      end

    end
  end
end
