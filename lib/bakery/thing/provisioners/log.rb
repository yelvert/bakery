module Bakery
  module Thing
    extend ActiveSupport::Autoload
    autoload :Provisioner
    autoload :Provisioners

    module Provisioners
      class Log < Provisioner::Base

        def run
          @message ||= super
          puts (@message || '').to_s.prepend("[#{Time.now}] [#{name}] ")
        end

      end

    end
  end
end

Bakery::Thing::Provisioners.register(:log, Bakery::Thing::Provisioners::Log)
