# -*- coding: utf-8 -*-

# Tasks related to the inventory.
class Inventory::Rake::Tasks::Inventory
  include Rake::DSL

  # Sets up tasks based on INVENTORY, optionally yields the task object for
  # further customization, then {#define}s the tasks.
  #
  # @param [Hash] options
  # @option options [Inventory] :inventory (Inventory::Rake::Tasks.inventory)
  #   The inventory to use
  # @option options [String] :pattern
  #   ('{ext/**/*.{[ch],rb},{lib/test}/**/*.rb}') The pattern to use when
  #   looking for files not listed in inventory
  # @yield [?]
  # @yieldparam [self] task
  def initialize(options = {})
    self.inventory = options.fetch(:inventory, Inventory::Rake::Tasks.inventory)
    self.pattern = options.fetch(:pattern, '{ext/**/*.{[ch],rb},{lib,test}/**/*.rb}')
    yield self if block_given?
    define
  end

  # Defines the following task:
  #
  # <dl>
  #   <dt>inventory:check</dt>
  #   <dd>Check that the inventory is correct by looking for files not listed
  #   in the inventory that match the pattern and for files listed in the
  #   inventory that don’t exist; depends on distclean.</dd>
  # </dl>
  def define
    desc 'Check that the inventory is correct'
    task :'inventory:check' => :distclean do
      diff = ((Dir[@pattern] -
               @inventory.extensions.map(&:source_files) -
               @inventory.lib_files -
               @inventory.unit_test_files).map{ |e| '%s: file not listed in inventory' % e } +
              @inventory.files.reject{ |e| File.exist? e }.map{ |e| '%s: file listed in inventory does not exist' % e })
      fail diff.join("\n") unless diff.empty?
      # TODO: puts 'inventory checks out' if verbose
    end
  end

  # @param [Inventory] value
  # @return [Inventory] The inventory to use: VALUE
  attr_writer :inventory

  # @param [String] value
  # @return [String] The pattern to use: VALUE
  attr_writer :pattern
end
