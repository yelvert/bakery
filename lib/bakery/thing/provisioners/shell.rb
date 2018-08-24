module Bakery
  module Thing
    extend ActiveSupport::Autoload
    autoload :Provisioner

    module Provisioner
      class Shell < Provisioner::Base
        require 'open3'

        argument :command, :string, default: ''
        argument :cwd, :path, default: Bakery.project.try(:root) || Bakery.root
        argument :options, :hash, default: {}.with_indifferent_access

        attr_reader :stdout, :stderr, :status, :result

        def run
          run_command
        end

        private

          def run_command
            return if @command_ran
            opts = { chdir: Pathname.new(cwd).expand_path }.
              with_indifferent_access.
              merge(options).
              tap {|o| o[:chdir] = o[:chdir].to_s }.
              symbolize_keys
            @stdout, @stderr, @status = Open3.capture3(command, opts)
            @result = @stdout.strip
          end

      end
      register :shell, Shell

    end
  end
end
