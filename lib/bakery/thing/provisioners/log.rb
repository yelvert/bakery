module Bakery
  module Thing
    extend ActiveSupport::Autoload
    autoload :Provisioner

    module Provisioner
      class Log < Base

        argument(:status, :symbol) { :info }
        argument(:message, :string) { '' }
        argument(:tag, :string)
        argument(:tags, :array) { [] }

        def full_message
          (message || '').to_s.gsub(/^/, tag_str+' ')
        end

        def run
          puts full_message
        end

        private

          def default_tags
            @default_tags ||= [
              Time.now,
              *(args[2..-1] || [])
            ]
          end

          def all_tags
            [default_tags, status, tag, tags].flatten.compact
          end

          def added_tags
            @added_tags ||= []
          end

          def tag_str
            all_tags.map{|tag| "[#{tag}]"}.join(' ')
          end

      end
      register Log

    end
  end
end
