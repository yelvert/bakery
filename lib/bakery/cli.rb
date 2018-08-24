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

    desc 'runner CODE_OR_FILE ARGS', 'Run a command or file'
    def runner(code_or_file, *command_argv)
      ARGV.replace(command_argv)
      if code_or_file == "-"
        eval($stdin.read, TOPLEVEL_BINDING, "stdin")
      elsif File.exist?(code_or_file)
        $0 = code_or_file
        Kernel.load code_or_file
      else
        eval(code_or_file, TOPLEVEL_BINDING, __FILE__, __LINE__)
      end
    end
    map 'r' => :runner

  end
end

Bakery::CLI.eager_load!
