module Bakery
  class CLI < Thor
    extend ActiveSupport::Autoload
    eager_autoload do
      autoload :Commands
    end

    package_name 'bakery'

    desc 'console', 'Start a console'
    def console
      Pry.start(TOPLEVEL_BINDING.eval('self'))
    end
    map 'c' => :console

  end
end

Bakery::CLI.eager_load!
