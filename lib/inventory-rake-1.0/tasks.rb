# -*- coding: utf-8 -*-

# Namespace for Rake tasks using an Inventory.
module Inventory::Rake::Tasks
  @mostlycleanfiles, @cleanfiles, @distcleanfiles = [], [], []

  class << self
    # @param [Inventory] value
    # @return [Inventory] The default inventory to use for tasks
    attr_accessor :inventory

    # @return [Array<String>] The files to clean when running the “mostlyclean”
    #   task
    attr_reader :mostlycleanfiles

    # @return [Array<String>] The files to clean when running the “clean” task
    attr_reader :cleanfiles

    # @return [Array<String>] The files to clean when running the “distclean”
    #   task
    attr_reader :distcleanfiles

    # Sets the default {.inventory} to INVENTORY, then defines {Clean},
    # {Compile}, {Inventory}, and {Gem} tasks.
    #
    # A task named “check” will already have been created.  This task is meant
    # to depend on tasks that check the package before distribution.
    #
    # @param [Inventory] inventory
    # @param [Hash] options
    # @option options [#to_proc] :gem (proc{}) Block to pass to
    #   {Gem#initialize}
    # @return [self]
    def define(inventory, options = {})
      self.inventory = inventory
      Clean.define
      Compile.new :inventory => inventory
      Inventory.new :inventory => inventory
      Gem.new(:inventory => inventory, &options.fetch(:gem, proc{}))
      self
    end

    # Yields if the top-level tasks that Rake’s running don’t include any of
    #
    # * deps:install
    # * deps:install:user
    # * gem:deps:install
    # * gem:deps:install:user
    #
    # that is, Rake’s not being run to install the inventory’s dependencies.
    #
    # @yield [?]
    # @return [self]
    def unless_installing_dependencies
      yield if (%w'deps:install
                   deps:install:user
                   gem:deps:install
                   gem:deps:install:user' &
                Rake.application.top_level_tasks).empty?
      self
    end
  end
end
