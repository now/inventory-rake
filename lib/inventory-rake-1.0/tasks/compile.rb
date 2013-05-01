# -*- coding: utf-8 -*-

# Defines tasks for compiling and cleaning extensions.
class Inventory::Rake::Tasks::Compile
  include Rake::DSL

  # Sets up tasks based on INVENTORY, optionally yields the task object for
  # further customization, then {#define}s the tasks.
  #
  # @param [Hash] options
  # @option options [Inventory] :inventory (Inventory::Rake::Tasks.inventory)
  #   The inventory to use
  # @yield [?]
  # @yieldparam [self] task
  def initialize(options = {})
    self.inventory = options.fetch(:inventory, Inventory::Rake::Tasks.inventory)
    yield self if block_given?
    define
  end

  # Defines the following task:
  #
  # <dl>
  #   <dt>compile</dt>
  #   <dd>Compile all extensions; depends on each compile:<em>name</em>.</dd>
  # </dl>
  #
  # Then, for each extension in the inventory, define the following tasks:
  #
  # <dl>
  #   <dt>compile:<em>name</em></dt>
  #   <dd>Compile extension <em>name</em>; depends on
  #   lib/<em>path</em>/<em>so</em> file.</dd>
  #
  #   <dt>lib/<em>path</em>/<em>so</em></dt>
  #   <dd>Installed dynamic library of extension <em>name</em> inside inventory
  #   path; depends on ext/<em>name</em>/<em>so</em>.</dd>
  #
  #   <dt>ext/<em>name</em>/<em>so</em></dt>
  #   <dd>Dynamic library of extension <em>name</em>; depends on
  #   ext/<em>name</em>/Makefile and the source files of the extension.</dd>
  #
  #   <dt>ext/<em>name</em>/Makefile</dt>
  #   <dd>Makefile for extension <em>name</em>; depends on inventory path,
  #   ext/<em>name</em>/extconf.rb file, and ext/<em>name</em>/depend file.
  #   Will be created by extconf.rb, which may take options from environment
  #   variable <em>name#upcase</em><code>_EXTCONF_OPTIONS</code> or
  #   <code>EXTCONF_OPTIONS</code> if defined.</dd>
  #
  #
  #   <dt>clean:<em>name</em></dt>
  #   <dd>Clean files built for extension <em>name</em>; depended upon by
  #   clean.</dd>
  # </dl>
  #
  # Finally, if defined, the test task is set to depend on the compile task.
  def define
    desc 'Compile extensions' unless Rake::Task.task_defined? :compile
    task :compile

    @inventory.extensions.each do |extension|
      name = :"compile:#{extension}"
      makefile = '%s/Makefile' % extension.directory
      ext_so = '%s/%s.%s' % [extension.directory,
                             extension.name.delete('-'),
                             RbConfig::CONFIG['DLEXT']]
      lib_so = 'lib/%s/%s' % [@inventory.package_path, File.basename(ext_so)]

      task :compile => name

      task name => lib_so

      file lib_so => ext_so do
        install ext_so, lib_so
      end

      file ext_so => [makefile] + extension.source_files do
        sh 'make -C %s' % extension.directory
      end

      file makefile => [@inventory.path, extension.extconf, extension.depend] do
        Dir.chdir extension.directory do
          options = ENV['%s_EXTCONF_OPTIONS' % extension.to_s.upcase] || ENV['EXTCONF_OPTIONS']
          file = '%s.options' % File.basename(extension.extconf)
          write = options
          options = begin
                      File.open(file, 'rb', &:read)
                    rescue Errno::ENOENT
                      nil
                    end unless options
          ruby '%s %s' % [File.basename(extension.extconf), options]
          File.open(file, 'wb'){ |f| f.write(options) } if write
        end
      end

      clean_name = :"clean:#{extension}"
      desc 'Clean files built for extension %s' % extension
      task clean_name do
        sh 'make -C %s %s' % [extension.directory, rule]
      end

      task :clean => clean_name
    end

    task :test => :compile if Rake::Task.task_defined? :test
  end

  # @param [Inventory] value
  # @return [Inventory] The inventory to use: VALUE
  attr_writer :inventory
end
