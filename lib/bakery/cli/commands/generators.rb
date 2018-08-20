module Bakery
  class CLI < Thor
    module Commands
      extend ActiveSupport::Autoload
      autoload :Base

      module Generators
        class Generate < Base
          package_name 'generate'
          register_with_description 'Generate Stuff'
          register_with_alias 'g'
          Bakery::Generators::Thing.register_with(self)
        end

        class Destroy < Base
          package_name 'destroy'
          register_with_description 'Destroy Stuff'
          register_with_alias 'd'
          Bakery::Generators::Thing.register_with(self)
        end

        class << self
          def register_with(thor)
            Bakery::CLI::Commands::Generators::Generate.register_with(thor)
            Bakery::CLI::Commands::Generators::Destroy.register_with(thor)
          end
        end

      end
    end
  end
end
