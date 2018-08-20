module Bakery
  module Generators
    extend ActiveSupport::Autoload
    autoload :Base

    class Project < Base
      argument  :name,
                desc: 'The name of the project',
                required: true,
                type: :string

      class_option  :path,
                    desc: 'The path of the project',
                    required: false,
                    type: :string

      def directory_structure
        directory('template', destination)
        if invoke? && !pretend?
          FileUtils.chmod('u+x', destination.join('bin/bakery'))
        end
      end

      def bundle
        if invoke? && !pretend?
          Dir.chdir(destination) do
            system('bundle install')
          end
        end
      end

      no_commands do

        def class_name
          name.classify
        end

        def underscored_name
          name.underscore
        end

        def path
          @path ||= if options[:path].present?
            Pathname.new(options[:path]).expand_path
          else
            Pathname.pwd.join(name)
          end
        end

        def destination(relative = :__ROOT__)
          if relative === :__ROOT__
            @destination ||= self.path
          else
            self.path.join(relative)
          end
        end

        def gem_path
          Bakery.root
        end

      end

    end
  end
end