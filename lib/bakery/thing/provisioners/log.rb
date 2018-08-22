module Bakery
  module Thing
    extend ActiveSupport::Autoload
    autoload :Provisioner
    autoload :Provisioners

    module Provisioners
      class Log < Provisioner::Base

        argument :status, default: :log
        argument :message, default: ''

        def tags
          [default_tags, status, added_tags].flatten
        end

        def tag(value)
          added_tags << value
        end

        def full_message
          (message || '').to_s.prepend(tags.map{|tag| "[#{tag}]"}.join(' ')+' ')
        end

        def after_run
          puts full_message
        end

        private

          def default_tags
            @default_tags ||= [
              Time.now,
              name,
              *(args[2..-1] || [])
            ]
          end

          def added_tags
            @added_tags ||= []
          end

      end

    end
  end
end

Bakery::Thing::Provisioners.register(:log, Bakery::Thing::Provisioners::Log)
