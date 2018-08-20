module Bakery
  class CLI < Thor
    module Commands
      class Project < Base

        package_name 'project'
        register_with_description 'Manage bakery projects'

        add_runtime_options!

        desc 'create NAME', 'Create a new bakery project'
        method_option :path, desc: 'Where the project should be created'
        def create(name)
          Bakery::Generators::Project.generate([name], options)
        end

        desc 'destroy PATH', 'Destroy the Thing Type: NAME'
        def destroy(path)
          path = Pathname.new(path).expand_path
          Bakery::Generators::Project.destroy([path], options)
        end

      end
    end
  end
end
