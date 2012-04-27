# -*- coding: utf-8 -*-

$:.unshift File.expand_path('../lib', __FILE__)
require 'inventory/rake-1.0'

Inventory::Rake::Tasks.define Inventory::Rake::Version, :gem => proc{ |_, s|
  s.author = 'Nikolai Weibull'
  s.email = 'now@bitwi.se'
  s.homepage = 'https://github.com/now/inventory-rake'
}

Inventory::Rake::Tasks.unless_installing_dependencies do
  require 'lookout/rake-3.0'
  Lookout::Rake::Tasks::Test.new
end
