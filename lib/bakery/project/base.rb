module Bakery
  module Project
    class Base

      cattr_reader :paths
      @@paths = {
        things: ['things']
      }.with_indifferent_access

      attr_reader :root

      class << self

        def module_name
          @module_name ||= Bakery.project.class.to_s.split('::').reverse.drop(1).reverse.join('::')
        end

      end

      def initialize(root)
        @root = Pathname.new(root)
        Bakery.initialize!(self)
        paths.
          values.
          flatten.
          map(&self.root.method(:join)).
          map(&:to_s).
          map(&ActiveSupport::Dependencies.autoload_paths.method(:<<))
      end
    end
  end
end
