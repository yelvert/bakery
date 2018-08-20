module Bakery
  class CLI < Thor
    module Commands
      class Base < Thor
        include Bakery::CLI::RegisterWith
        include Thor::Actions

        class << self

          def project_only!
            @hide = true
          end

        end

        no_commands do

          # def ensure_option(opt, statement, *args)
          #   options[opt] = ask(statement, *args) unless options[opt].present?
          #   raise RequiredArgumentMissingError, ""
          #   options[opt]
          # end

        end

      end
    end
  end
end
