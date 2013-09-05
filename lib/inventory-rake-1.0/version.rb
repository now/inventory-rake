# -*- coding: utf-8 -*-

require 'inventory-1.0'

module Inventory::Rake
  Version = Inventory.new(1, 6, 3){
    authors{
      author 'Nikolai Weibull', 'now@disu.se'
    }

    homepage 'http://disu.se/software/inventory-rake/'

    licenses{
      license 'LGPLv3+',
              'GNU Lesser General Public License, version 3 or later',
              'http://www.gnu.org/licenses/'
    }

    def dependencies
      super + Inventory::Dependencies.new{
        development 'inventory-rake-tasks-yard', 1, 4, 0
        development 'lookout', 3, 0, 0
        development 'lookout-rake', 3, 1, 0
        development 'yard', 0, 8, 0
        development 'yard-heuristics', 1, 2, 0
        runtime 'rake', 10, 0, 0, :feature => 'rake'
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
