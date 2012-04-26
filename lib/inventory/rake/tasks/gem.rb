# -*- coding: utf-8 -*-

class Inventory::Rake::Tasks::Gem
  include Rake::DSL

  def initialize(options = {})
    self.inventory = options.fetch(:inventory, Inventory::Rake::Tasks.inventory)
    self.specification = options.fetch(:specification,
                                       Gem::Specification.new{ |s|
                                         next unless @inventory

                                         s.name = @inventory.package
                                         s.version = @inventory.to_s # TODO: We could probably skip #to_s

                                         s.description = IO.read('README')
                                         s.summary = s.description[/^.*?\./].lstrip

                                         s.files = @inventory.files # TODO: We can skip #files and rely on #to_a

                                         s.require_paths = @inventory.lib_directories

                                         @inventory.dependencies.add_to_gem_specification s
                                       })
    yield self, @specification if block_given?
    define
  end

  def define
    desc 'Create specifications' unless Rake::Task.task_defined? :spec
    task :spec => :'gem:spec'

    gemspec = '%s.gemspec' % @specification.name
    Inventory::Rake::Tasks.cleanfiles << gemspec

    desc 'Create gem specification' unless Rake::Task.task_defined? :'gem:spec'
    task :'gem:spec' => gemspec

    file gemspec => %w'Rakefile README' + [@inventory.path] do |t|
      tmp = '%s.tmp' % t.name
      rm([t.name, tmp], :force => true)
      rake_output_message 'gem specification --ruby %s > %s' %
        [@specification.name, tmp] if verbose
      File.open(tmp, 'wb') do |f|
        f.write @specification.to_ruby
      end
      chmod File.stat(tmp).mode & ~0222, tmp
      mv tmp, t.name
     end

    desc 'Create files for distribution' unless Rake::Task.task_defined? :dist
    task :dist => :'gem:dist'

    desc 'Create %s for distribution' % @specification.file_name
    task :'gem:dist' => [:'inventory:check', @specification.file_name]
    file @specification.file_name => @specification.files do
      require 'rubygems' unless defined? Gem
      rake_output_message 'gem build %s' % gemspec if verbose
      Gem::Builder.new(@specification).build
    end

    desc 'Check files before distribution' unless
      Rake::Task.task_defined? :'dist:check'
    task :'dist:check' => [:dist, :'gem:dist:check']

    desc 'Check %s before distribution' % @specification.file_name
    task :'gem:dist:check' => :'gem:dist' do
      require 'rubygems' unless defined? Gem
      require 'rubygems/installer' unless defined? Gem::Installer
      checkdir = @specification.full_name
      rake_output_message 'gem unpack %s --target %s' %
        [@specification.file_name, checkdir] if verbose
      Gem::Installer.new(@specification.file_name, :unpack => true).
        unpack File.expand_path(checkdir)
      chdir checkdir do
        sh '%s %sinventory:check check' %
          [Rake.application.name, Rake.application.options.silent ? '-s ' : '']
      end
      rm_r checkdir
    end

    desc 'Install dependencies on the local system' unless
      Rake::Task.task_defined? :'deps:install'
    task :'deps:install' => :'gem:deps:install'

    desc 'Install dependencies in ruby gem directory'
    task :'gem:deps:install' do
      require 'rubygems' unless defined? Gem
      require 'rubygems/dependency_installer' unless defined? Gem::DependencyInstaller
      @specification.dependencies.each do |dependency|
        rake_output_message "gem install %s -v '%s'" % [dependency.name, dependency.requirement] if verbose
        Gem::DependencyInstaller.new.install dependency.name, dependency.requirement
      end
    end

    desc 'Install dependencies for the current user' unless
      Rake::Task.task_defined? :'deps:install:user'
    task :'deps:install:user' => :'gem:deps:install:user'

    desc 'Install dependencies for the current user'
    task :'gem:deps:install:user' do
      require 'rubygems' unless defined? Gem
      require 'rubygems/dependency_installer' unless defined? Gem::DependencyInstaller
      @specification.dependencies.each do |dependency|
        rake_output_message "gem install --user-install --bindir %s %s -v '%s'" %
          [Gem.bindir(Gem.user_dir), dependency.name, dependency.requirement] if verbose
        Gem::DependencyInstaller.
          new(:user_install => true,
              :bindir => Gem.bindir(Gem.user_dir)).
          install dependency.name, dependency.requirement
      end
    end

    desc 'Install distribution files on the local system' unless
      Rake::Task.task_defined? :install
    task :install => :'gem:install'

    desc 'Install %s in ruby gem directory' %
      @specification.file_name
    task :'gem:install' => :'gem:dist' do |t|
      require 'rubygems' unless defined? Gem
      require 'rubygems/dependency_installer' unless defined? Gem::DependencyInstaller
      rake_output_message 'gem install %s' % @specification.file_name if verbose
      Gem::DependencyInstaller.
        new(:ignore_dependencies => true).
        install @specification.file_name
    end

    desc 'Install distribution files for the current user' unless
      Rake::Task.task_defined? :'install:user'
    task :'install:user' => :'gem:install:user'

    desc 'Install %s in user gem directory' %
      @specification.file_name
    task :'gem:install:user' => :'gem:dist' do
      require 'rubygems' unless defined? Gem
      require 'rubygems/dependency_installer' unless defined? Gem::DependencyInstaller
      rake_output_message 'gem install --user-install --bindir %s %s' %
        [Gem.bindir(Gem.user_dir), @specification.file_name] if verbose
      Gem::DependencyInstaller.
        new(:ignore_dependencies => true,
            :user_install => true,
            :bindir => Gem.bindir(Gem.user_dir)).
        install @specification.file_name
    end

    desc 'Delete all files installed on the local system' unless
      Rake::Task.task_defined? :uninstall
    task :uninstall => :'gem:uninstall'

    desc 'Uninstall %s from ruby gem directory' % @specification.file_name
    task :'gem:uninstall' do
      require 'rubygems' unless defined? Gem
      # TODO: I have absolutely no idea why this is needed, but it is.
      require 'rubygems/user_interaction' unless defined? Gem::UserInteraction
      require 'rubygems/uninstaller' unless defined? Gem::Uninstaller
      rake_output_message 'gem uninstall --executables %s' % @specification.name if verbose
      Gem::Uninstaller.new(@specification.name,
                           :executables => true,
                           :version => @specification.version).uninstall
    end

    desc 'Delete all files installed for current user' unless
      Rake::Task.task_defined? :'uninstall:user'
    task :'uninstall:user' => :'gem:uninstall:user'

    desc 'Uninstall %s from user gem directory' % @specification.file_name
    task :'gem:uninstall:user' do
      require 'rubygems' unless defined? Gem
      # TODO: I have absolutely no idea why this is needed, but it is.
      require 'rubygems/user_interaction' unless defined? Gem::UserInteraction
      require 'rubygems/uninstaller' unless defined? Gem::Uninstaller
      rake_output_message 'gem uninstall --executables --install-dir %s %s' %
        [Gem.user_dir, @specification.name] if verbose
      Gem::Uninstaller.new(@specification.name,
                           :executables => true,
                           :install_dir => Gem.user_dir,
                           :version => @specification.version).uninstall
    end

    desc 'Push distribution files to distribution hubs' unless
      Rake::Task.task_defined? :push
    task :push => :'gem:push'

    desc 'Push %s to rubygems.org' % @specification.file_name
    task :'gem:push' => :'gem:dist:check' do
      sh 'gem push -%s-verbose %s' % [verbose ? '' : '-no', @specification.file_name]
    end
  end

  attr_writer :inventory, :specification
end
