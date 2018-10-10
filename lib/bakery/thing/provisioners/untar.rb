module Bakery
  module Thing
    extend ActiveSupport::Autoload
    autoload :Provisioner

    module Provisioner
      class Untar < Base

        require 'rubygems/package'
        require 'zlib'

        argument(:src, :path)
        argument(:dest, :path) { Pathname.new(Dir.mktmpdir) }
        argument(:force, :boolean) { false }
        argument(:log_progress, :boolean) { true }
        argument(:log_tags, :array) { [] }

        attr_reader :destination, :destinations, :files, :archive

        def run
          verify_src!
          verify_dest!
          log('Opening archive')
          @archive = Gem::Package::TarReader.new(Zlib::GzipReader.open(src))
          @archive.rewind
          @destinations = []
          @files = []
          @archive.each do |entry|
            outpath = dest.join(entry.full_name)
            if entry.directory?
              outpath.mkpath
              log("Extracted: #{entry.full_name}") if log_progress?
              @destinations << outpath if outpath.parent == dest
            elsif entry.file?
              outpath.write(entry.read)
              outpath.chmod(entry.header.mode)
              log("Extracted: #{entry.full_name}") if log_progress?
              @files << outpath
            end
          end
          @files.freeze
          @destinations.freeze
          @destination = destinations.first if destinations.length == 1
          @file = files.first if files.length == 1
          @archive.close
          log("Closed archive")
        end

        private

          def verify_src!
            raise "Untar Provisioner src must be set" unless src
            raise "Untar Provisioner src must be a file: #{src.inspect}" unless src.file?
          end

          def verify_dest!
            raise "Untar Provisioner dest must be set" unless dest
            dest.rmtree if force? && dest.directory?
            dest.mkpath
          end

          def log_tag
            "Untar: #{{src: src, dest: dest}.to_json}"
          end

          def full_log_tags(*additional)
            Array(log_tags) + [log_tag] + additional
          end

          def log(message, status = :info)
            p.log(status: status, tags: full_log_tags, message: message)
          end

      end
      register Untar

    end
  end
end
