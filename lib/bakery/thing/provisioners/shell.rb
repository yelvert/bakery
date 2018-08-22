module Bakery
  module Thing
    extend ActiveSupport::Autoload
    autoload :Provisioner

    module Provisioner
      class Shell < Provisioner::Base
        require 'open3'

        argument :command, default: ''
        argument :cwd, default: Bakery.project.root
        argument :options, default: {}.with_indifferent_access

        attr_reader :stdout, :stderr, :status, :result

        def run
          run_command
        end

        private

          def run_command
            return if @command_ran
            @stdout, @stderr, @status = Open3.capture3(command, opts)
            @result = @stdout.strip
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
      register :shell, Shell

    end
  end
end
