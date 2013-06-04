# -*- coding: utf-8 -*-

# Tasks for cleaning up a project directory.
class Inventory::Rake::Tasks::Clean
  include Rake::DSL

  class << self
    include Rake::DSL

    def define
      # Defines the following tasks:
      #
      # <dl>
      #   <dt>mostlyclean</dt>
      #   <dd>Delete targets built by rake that are ofter rebuilt.</dd>
      #
      #   <dt>clean</dt>
      #   <dd>Delete targets builty by rake; depends on mostlyclean.</dd>
      #
      #   <dt>distclean</dt>
      #   <dd>Delete all files not meant for distribution; depends on
      #   clean.</dd>
      # </dl>
      desc 'Delete targets built by rake that are often rebuilt'
      new :mostlyclean, Inventory::Rake::Tasks.mostlycleanfiles

      desc 'Delete targets built by rake'
      new :clean, Inventory::Rake::Tasks.cleanfiles
      task :clean => :mostlyclean

      desc 'Delete all files not meant for distribution'
      new :distclean, Inventory::Rake::Tasks.distcleanfiles
      task :distclean => :clean
    end
  end

  # Sets up a cleaning task {#name} that’ll delete {#files}, optionally yields
  # the task for further customization, then {#define}s the task.
  #
  # @param [Symbol] name
  # @param [Array<String>] files
  # @yield [?]
  # @yieldparam [self] task
  def initialize(name, files = [])
    @name, @files = name, files
    yield self if block_given?
    define
  end

  # Defines the task {#name} that’ll delete {#files}.
  def define
    task name do
      rm files, :force => true unless files.empty?
    end
  end

  # @param [Symbol] value
  # @return [Symbol] The name of the task
  attr_accessor :name

  # @param [Array<String>] value
  # @return [Array<String>] The files to delete
  attr_accessor :files
end
