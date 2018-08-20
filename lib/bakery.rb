
# require 'rubygems'
# ENV['BUNDLE_GEMFILE'] ||= File.expand_path(File.join('..', 'Gemfile'), __dir__)
# require 'bundler/setup'

ENV['BAKERY_DEBUG'] = 'true' # TODO: Remove

if ENV.member? 'BAKERY_DEBUG'
  require 'pry'
  require 'pry-doc'
  require 'pry-nav'
  require 'pry-remote'
end

# bundler_groups = [:default]
# bundler_groups << :debug if ENV.member? 'BAKERY_DEBUG'
# Bundler.require(*bundler_groups)
require 'thor'
require 'active_support'
require 'active_support/core_ext/hash/indifferent_access'
ActiveSupport::Dependencies.autoload_paths << File.expand_path(__dir__)
$LOAD_PATH.unshift(File.expand_path(__dir__))

module Bakery
  extend ActiveSupport::Autoload
  autoload :Project

  class << self
    attr_reader :initialized, :root, :project

    def initialize!(project = nil)
      raise StandardError.new('Bakery has already been initialized!') if defined?(@initialized)
      @root = Pathname.new(File.expand_path('..', __dir__))
      @project = project
      @initialized = true
    end

    def project?
      project.is_a? Project::Base
    end

  end
end
