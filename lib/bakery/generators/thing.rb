module Bakery
  module Generators
    class Thing < Base
      register_with_description 'Generate and destroy Things in the current Project'

      argument  :name,
                desc: 'The name of the Thing',
                required: true,
                type: :string

      argument  :attributes,
                desc: 'The Things attributes',
                required: false,
                type: :hash,
                default: {}.with_indifferent_access

      def thing_file
        template File.join('templates', 'thing.rb.tt'), destination.join('things', "#{underscored_name}_thing.rb")
      end

      no_commands do

        def class_name
          name.classify
        end

        def underscored_name
          name.underscore
        end

        def destination
          Bakery.project.root
        end

        def module_name
          Bakery.project.class.to_s.split( '::' ).reverse.drop(1).reverse.join('::')
        end

      end

    end
  end
end
