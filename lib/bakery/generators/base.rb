module Bakery
  module Generators
    class Base < Thor::Group
      include Thor::Actions
      include Bakery::CLI::RegisterWith

      add_runtime_options!

      class << self

        def source_root
          @source_root ||= File.expand_path(class_name.underscore, __dir__)
        end

        def generate(args, opts)
          new(args, opts, {behavior: :invoke}).invoke_all()
        end

        def destroy(args, opts)
          new(args, opts, {behavior: :revoke}).invoke_all()
        end

      end

      no_commands do

        def initialize(args = [], options = {}, config = {})
          if config[:current_command].present? && !config[:behavior].present?
            case config[:current_command].ancestor_name
            when 'generate'
              config[:behavior] = 'invoke'
            when 'destroy'
              config[:behavior] = 'revoke'
            end
          end
          super(args, options, config)
        end

        def invoke? ; behavior == :invoke ; end
        def revoke? ; behavior == :revoke ; end

        def force?    ; !!options[:force]   ; end
        def pretend?  ; !!options[:pretend] ; end
        def quiet?    ; !!options[:quiet]   ; end
        def skip?     ; !!options[:skip]    ; end

      end

      class ActionNotFoundError < StandardError
        def initialize(klass, action)
          super("Generator #{klass} does not have the requested action: #{action}")
        end
      end

    end
  end
end