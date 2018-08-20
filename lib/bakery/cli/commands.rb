module Bakery
  class CLI < Thor
    module Commands
      extend ActiveSupport::Autoload
      autoload :Project
      autoload :Generators

      class << self
        @commands = []

        @commands << Project if !Bakery.project?
        @commands << Generators if Bakery.project?

        @commands.each {|klass| klass.register_with(Bakery::CLI) }
      end
    end
  end
end
