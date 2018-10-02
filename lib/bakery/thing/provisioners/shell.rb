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
        argument :on_stdout, :block, default: ->(line) {}
        argument :on_stderr, :block, default: ->(line) {}

        def run
          run_command
        end

        def stdout_lines ; @stdout_lines ||= [] ; end
        def stderr_lines ; @stderr_lines ||= [] ; end

        def stdout ; stdout_lines.join("\n") ; end
        def stderr ; stderr_lines.join("\n") ; end

        def result ; stdout.strip ; end

        private

          def log?
            !!( options.with_indifferent_access.fetch(:log) { true } )
          end

          def log_tags(*additional)
            Array( options.with_indifferent_access.fetch(:log_tags) { [] } ) + additional
          end

          def run_command
            return if @command_ran
            opts = { chdir: Pathname.new(cwd).expand_path }.
              with_indifferent_access.
              merge(options).
              tap {|o| o[:chdir] = o[:chdir].to_s }.
              symbolize_keys
            # @stdout, @stderr, @status = Open3.capture3(command, opts)
            # @result = @stdout.strip
            Open3.popen3(command, opts) do |stdin, stdout, stderr, thread|
              { :out => stdout, :err => stderr }.map do |key, stream|
                Thread.new do
                  until (line = stream.gets).nil? do
                    if key == :out
                      execute_on_stdout line
                    else
                      execute_on_stderr line
                    end
                  end
                end
              end.each(&:value)
              thread.join
            end
          end

          def execute_on_stdout(line)
            if log?
              this = self
              log do
                this.send(:log_tags, :stdout).each(&method(:tag))
                message line
              end
            end
            instance_exec(line, &on_stdout) if on_stdout.is_a? Proc
          end

          def execute_on_stderr(line)
            if log?
              this = self
              log do
                this.send(:log_tags, :stderr).each(&method(:tag))
                message line
              end
            end
            instance_exec(line, &on_stderr) if on_stderr.is_a? Proc
          end

      end
      register :shell, Shell

    end
  end
end
