module Bakery
  module Thing
    extend ActiveSupport::Autoload
    autoload :Provisioner
    autoload :Provisioners

    module Provisioners
      class Shell < Provisioner::Base
        require 'open3'

        argument :command, default: ''
        argument :cwd, default: Bakery.project.root
        argument :options, default: {}.with_indifferent_access

        attr_reader :stdout, :stderr, :status, :results

        def after_run
          run_command
        end

        private

          def run_command
            return if @command_ran
            @stdout, @stderr, @status = Open3.capture3(command, opts)
            @results = @stdout.strip
          end

          def opts
            @opts ||= {
              chdir: Pathname.new(cwd).expand_path
            }.
              with_indifferent_access.
              merge(options).
              tap {|o| o[:chdir] = o[:chdir].to_s }.
              symbolize_keys
          end

      end

    end
  end
end

Bakery::Thing::Provisioners.register(:shell, Bakery::Thing::Provisioners::Shell)
