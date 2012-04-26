# -*- coding: utf-8 -*-

require 'lookout/rake-3.0'

$:.unshift File.expand_path('../lib', __FILE__)
require 'inventory/rake-1.0'

Inventory::Rake::Tasks.define Inventory::Rake::Version, :gem => proc{ |_, s|
  s.author = 'Nikolai Weibull'
  s.email = 'now@bitwi.se'
  s.homepage = 'https://github.com/now/inventory-rake'
}
Lookout::Rake::Tasks::Test.new
