PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")
require 'capybara/dsl'

Capybara.app = Padrino.application

RSpec.configure do |conf|
  conf.include Capybara::DSL
end
