# -*- coding: utf-8 -*-

require 'inventory-1.0'

module Inventory::Rake
  Version = Inventory.new(1, 2, 0){
    def dependencies
      super + Inventory::Dependencies.new{
        optional 'rake', 0, 9, 2
      }
    end

    def requires
      %w'
        rake
      '
    end

    def libs
      %w'
        inventory/rake/tasks.rb
        inventory/rake/tasks/check.rb
        inventory/rake/tasks/clean.rb
        inventory/rake/tasks/gem.rb
        inventory/rake/tasks/inventory.rb
      '
    end
  }
end
