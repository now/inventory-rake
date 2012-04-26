# -*- coding: utf-8 -*-

# Namespace for Rake tasks.
module Inventory::Rake::Tasks
  @mostlycleanfiles, @cleanfiles, @distcleanfiles = [], [], []

  class << self
    attr_accessor :inventory

    attr_reader :mostlycleanfiles, :cleanfiles, :distcleanfiles

    def define(inventory, options = {})
      self.inventory = inventory
      Clean.define
      Inventory.new(:inventory => inventory)
      Gem.new(:inventory => inventory, &(options.fetch(:gem, proc{ })))
    end
  end
end
