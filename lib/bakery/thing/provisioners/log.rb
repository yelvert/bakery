module Bakery
  module Thing
    extend ActiveSupport::Autoload
    autoload :Provisioner

    module Provisioner
      class Log < Base

        argument(:status, :symbol) { :info }
        argument(:message, :string) { '' }

        def tags
          [default_tags, status, added_tags].flatten
        end

        def tag(value)
          added_tags << value
        end

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

          def added_tags
            @added_tags ||= []
          end

          def tag_str
            tags.map{|tag| "[#{tag}]"}.join(' ')
          end

      end
      register :log, Log

    end
  end
end
