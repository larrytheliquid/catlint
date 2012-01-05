require File.expand_path('../config/boot.rb', __FILE__)
require 'padrino-core/cli/rake'
PadrinoTasks.init

if [:development, :test].include? Padrino.env
  desc "Run specs by default"
  task :default => :spec
end
