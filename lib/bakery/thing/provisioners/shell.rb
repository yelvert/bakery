module Bakery
  module Thing
    extend ActiveSupport::Autoload
    autoload :Provisioner

    module Provisioner
      class Shell < Provisioner::Base
        require 'open3'

        argument(:command, :string) { '' }
        argument(:cwd, :path) { Bakery.project.try(:root) || Bakery.root }
        argument(:log_output, :boolean) { true }
        argument(:log_tags, :array) { [] }
        argument(:options, :hash) { {}.with_indifferent_access }
        argument(:on_stdout, :block)
        argument(:on_stderr, :block)

        def run
          run_command
        end

        def stdout_lines ; @stdout_lines ||= [] ; end
        def stderr_lines ; @stderr_lines ||= [] ; end

        def stdout ; stdout_lines.join("\n") ; end
        def stderr ; stderr_lines.join("\n") ; end

        def result ; stdout.strip ; end

        private

          def full_log_tags(*additional)
            Array(log_tags) + additional
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
                      stdout_lines << line
                      execute_on_stdout line
                    else
                      stderr_lines << line
                      execute_on_stderr line
                    end
                  end
                end
              end.each(&:value)
              thread.join
            end
          end

          def execute_on_stdout(line)
            if log_output?
              log(line, :stdout) if log_output?
            end
            instance_exec(line, &on_stdout) if on_stdout.is_a? Proc
          end

          def execute_on_stderr(line)
            log(line, :stderr) if log_output?
            instance_exec(line, &on_stderr) if on_stderr.is_a? Proc
          end

          def log(message, out)
            p.log(status: out, tags: full_log_tags, message: message)
          end

      end
      register Shell

    end
  end
end
