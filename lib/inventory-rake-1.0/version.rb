# -*- coding: utf-8 -*-

require 'inventory-1.0'

module Inventory::Rake
  Version = Inventory.new(1, 4, 0){
    def dependencies
      super + Inventory::Dependencies.new{
        development 'inventory-rake-tasks-yard', 1, 3, 0
        development 'lookout', 3, 0, 0
        development 'lookout-rake', 3, 0, 0
        development 'yard', 0, 8, 0
        development 'yard-heuristics', 1, 1, 0
        runtime 'rake', 0, 9, 2, :feature => 'rake'
      }
    end

    def package_libs
      %w[tasks.rb
         tasks/check.rb
         tasks/clean.rb
         tasks/compile.rb
         tasks/gem.rb
         tasks/inventory.rb]
    end

    def additional_libs
      super + %w[inventory/rake-1.0.rb]
    end

    def unit_tests
      super - %w[inventory/rake-1.0.rb]
    end
  }
end
