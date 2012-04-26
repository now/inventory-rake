# -*- coding: utf-8 -*-

class Inventory::Rake::Tasks::Inventory
  include Rake::DSL

  def initialize(options = {})
    self.inventory = options.fetch(:inventory, Inventory::Rake::Tasks.inventory)
    yield self if block_given?
    define
  end

  def define
    desc 'Check that the inventory is correct'
    task :'inventory:check' do
      # TODO: Use directories from Inventory instead of hard-coding lib and
      # test/unit.  We want to check ext too?
      diff = ((Dir['{lib,test/unit}/**/*.rb'] -
               @inventory.lib_files -
               @inventory.unit_test_files).map{ |e| 'file not listed in inventory: %s' % e } +
              @inventory.files.reject{ |e| File.exist? e }.map{ |e| 'file listed in inventory does not exist: %s' % e })
      fail diff.join("\n") unless diff.empty?
      # TODO: puts 'inventory checks out' if verbose
    end
  end

  attr_writer :inventory
end
