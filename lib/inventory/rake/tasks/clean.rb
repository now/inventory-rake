# -*- coding: utf-8 -*-

class Inventory::Rake::Tasks::Clean
  include Rake::DSL

  class << self
    include Rake::DSL

    def define
      desc 'Delete targets built by rake that are often rebuilt'
      new :mostlyclean, Inventory::Rake::Tasks.mostlycleanfiles

      desc 'Delete targets built by rake'
      new :clean, Inventory::Rake::Tasks.cleanfiles
      task :clean => :mostlyclean

      desc 'Delete targets built by extconf.rb'
      new :distclean, Inventory::Rake::Tasks.distcleanfiles
      task :distclean => :clean
    end
  end

  def initialize(name, files = [])
    @name, @files = name, files
    define
  end

  def define
    task name do
      rm files, :force => true
    end
  end

  attr_accessor :name, :files
end
