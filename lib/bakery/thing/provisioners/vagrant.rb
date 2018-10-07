module Bakery
  module Thing
    module Provisioner
      extend ActiveSupport::Autoload
      autoload :Base

      class Vagrant < Base
        argument(:directory, :path) do
          Bakery.project.root.join('things', self.thing.class.to_s.underscore, 'vagrant')
        end

        def run
          verify_directory!
          log("Directory: #{directory}")
          vagrant_command = p.shell(cwd: directory, command: "vagrant status")
          # binding.pry
          # if vagrant_command.stderr.present?
          #   log do
          #     status :error
          #     tag log_tag
          #     message vagrant_command.stderr
          #   end
          # end
          # if vagrant_command.stdout.present?
          #   log do
          #     status :info
          #     tag log_tag
          #     message vagrant_command.stdout
          #   end
          # end
        end

        private

          def verify_directory!
            unless directory.directory?
              raise "#{self.class.class_name}'s `directory` must be a valid directory'"
            end
            unless vagrant_file_path.file?
              raise "#{self.class.class_name}'s `directory` must include a Vagrantfile"
            end
          end

          def vagrant_file_path
            directory.join('Vagrantfile')
          end

          def log_tag ; "Vagrant: #{name}" ; end

          def log(message, status = :info)
            p.log(status: status, message: message, tag: log_tag)
          end

      end
      register :vagrant, Vagrant

    end
  end
end
