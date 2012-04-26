# -*- coding: utf-8 -*-

# Namespace for Inventory, see {http://disu.se/software/inventory}.
class Inventory; end

# Namespace for Rake integration of Inventory.
module Inventory::Rake
  load File.expand_path('../rake/version.rb', __FILE__)
  Version.load
end
