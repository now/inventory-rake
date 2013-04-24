# -*- coding: utf-8 -*-

# Namespace for [Inventory](http://disu.se/software/inventory/).  The bulk of
# the library is in {Rake::Tasks}.
class Inventory; end

# Namespace for [Rake](http://rake.rubyforge.org/) integration of Inventory.
module Inventory::Rake
  load File.expand_path('../inventory-rake-1.0/version.rb', __FILE__)
  Version.load
end
