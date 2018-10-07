require 'down'

module Bakery
  module Thing
    extend ActiveSupport::Autoload
    autoload :Provisioner

    module Provisioner
      class Download < Base

        argument(:url, :uri, valid_schemes: %w[ http https ])
        argument(:dest, :path, expand: true)
        argument(:dest_dir, :path, expand: true)
        argument(:force, :boolean) { false }
        argument(:log_progress, :boolean) { true }
        argument(:log_tags, :array) { [] }
        argument(:log_steps, :integer) { 1 }
        argument(:on_progress, :block)

        attr_reader :tempfile, :content_length, :progress

        def run
          verify_url!

          this = self

          if dest.present? && dest.file? && !force?
            log do
              this.send(:full_log_tags).each(&method(:tag))
              message 'Skipping download: already exists'
            end
            return
          end

          log do
            this.send(:full_log_tags).each(&method(:tag))
            message 'Starting download'
          end

          @tempfile = Down.download(
            url,
            content_length_proc: method(:execute_content_length),
            progress_proc: method(:execute_on_progress),
          )

          log do
            this.send(:full_log_tags).each(&method(:tag))
            message 'Finished downloading file'
          end

          if dest.present? or dest_dir.present?
            log do
              this.send(:full_log_tags).each(&method(:tag))
              message 'Moving file to destination'
            end
            dest_dir.mkpath if dest_dir.present?
            binding.pry
            destination
            FileUtils.move(tempfile, destination, force: true)
            unless destination.file?
              raise DestError.new(self, :mv_fail)
            end
            log do
              this.send(:full_log_tags).each(&method(:tag))
              message 'Finished moving file to destination'
            end
          end

          log do
            this.send(:full_log_tags).each(&method(:tag))
            message 'Download Finished'
          end
        end

        def destination
          if dest
            dest
          elsif dest_dir
            if tempfile
              dest_dir.join(tempfile.original_filename)
            else
              dest_dir
            end
          elsif tempfile
            Pathname.new(tempfile)
          end
        end

        private

          def verify_url!
            raise UrlError.new(self, :missing) unless url.present?
          end

          def log_tag
            "Download: #{{url: url, destination: destination}.to_json}"
          end

          def full_log_tags(*additional)
            Array(log_tags) + [log_tag] + additional
          end

          def execute_content_length(content_length)
            return unless content_length.present?
            @content_length = content_length
            this = self
            log do
              this.send(:full_log_tags).each(&method(:tag))
              message "Content Length: #{this.content_length}"
            end
          end

          def execute_on_progress(progress)
            return unless progress.present? && content_length.present?
            if log_progress?
              @_last_log_progress ||= 0
              current_progress = ((progress.to_f / content_length)*100).round
              # puts "#{current_progress} = #{progress} / #{content_length}"
              if current_progress - @_last_log_progress >= log_steps
                this = self
                log do
                  this.send(:full_log_tags, :progress).each(&method(:tag))
                  message "#{current_progress}%"
                end
                @_last_log_progress = current_progress
              end
            end
            instance_exec &on_progress if on_progress.is_a? Proc
          end

        class UrlError < StandardError
          def initialize(instance, err)
            message = case err
            when :missing then "Download Provisioner #{instance.name} must be provided a `url`"
            else
              "Download Provisioner #{instance.name} has an invalid `url`: #{instance.url.inspect}"
            end
            super(message)
          end
        end

        class DestError < StandardError
          def initialize(instance, err)
            message = case err
            when :missing then "Download Provisioner #{instance.name} must be provided a `dest`"
            when :mv_fail then "Download Provisioner #{instance.name} failed to move the downloaded file from #{instance.tempfile} to #{instance.destination}"
            else
              "Download Provisioner #{instance.name} has an invalid `dest`: #{instance.url.inspect}"
            end
            super(message)
          end
        end

      end
      register :download, Download

    end
  end
end
