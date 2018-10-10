module Bakery
  module Thing
    extend ActiveSupport::Autoload
    autoload :Provisioner

    module Provisioner
      class Etcher < Base
        CLI_SOURCE_URL = 'https://github.com/resin-io/etcher/releases/download/v1.4.4/etcher-cli-1.4.4-darwin-x64.tar.gz'

        argument(:image_path, :path)
        argument(:image_url, :uri, valid_schemes: %w[ http https ])

        def run
          ensure_etcher
          download_image
        end

        private

          def cli_dir ; helper_path.join('etcher-cli') ; end

          def cli_path ; cli_dir.join('etcher') ; end

          def ensure_etcher
            return if cli_path.executable?
            download = p.download(url: CLI_SOURCE_URL, log_progress: false)
            untar = p.untar(src: download.destination, log_progress: false)
            cli_dir.mkpath
            untar.destination.rename cli_dir
          end

          def download_image
            return if image_path.try(:file?)
            return unless image_url
          end

      end
      register Etcher

    end
  end
end
