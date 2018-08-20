module Bakery
  class CLI < Thor
    module RegisterWith
      extend ActiveSupport::Concern

      included do

        class << self

          def register_with_subcommand_name(value = :getter)
            if value === :getter
              @register_with_subcommand_name || @package_name || self.to_s.split('::').last.underscore
            else
              @register_with_subcommand_name = value
            end
          end

          def register_with_usage(value = :getter)
            if value === :getter
              @register_with_usage || "#{self.register_with_subcommand_name} <command>"
            else
              @register_with_usage = value
            end
          end

          def register_with_description(value = :getter)
            if value === :getter
              @register_with_description
            else
              @register_with_description = value
            end
          end

          def register_with_aliases; @register_with_aliases ||= []; end

          def register_with_alias(*aliases)
            aliases = aliases.map(&:to_s)
            register_with_aliases.push(*aliases)
          end

          def register_with(klass, options = {})
            klass.register(
              self,
              register_with_subcommand_name,
              register_with_usage,
              register_with_description,
              options
            )
            klass.map(
              register_with_aliases.each_with_object({}) {|a, m| m[a] = register_with_subcommand_name }
            )
          end


        end

      end

    end
  end
end
