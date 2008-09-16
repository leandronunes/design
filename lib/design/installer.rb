require 'design'
require 'fileutils'

module Design

  # This module implements the installatoin of the files needed by design
  # plugin in the client Rails application
  module Installer

    # installs the needed files, assuming +root+ as the root directory of the
    # rails application. +root+ defaults to RAILS_ROOT
    #
    # When +verbose+ is +false+, a lot of output is supressed. +verbose+
    # defaults to +true+.
    def self.install(root = RAILS_ROOT, verbose = true)
      options = { :verbose => verbose }

      target = File.expand_path(File.join(root, 'public'))

      FileUtils.chdir(File.join(File.dirname(__FILE__), '..', '..', 'resources')) do |dir|
        files = Dir.glob('**/*').select {|item| ! (item =~ /\.svn/) }
        files.select {|item| File.directory?(item)}.each do |file|
          target_file = File.join(target, file)
          if File.exists?(target_file)
            puts "Info: not creating #{target}/#{file}" if verbose
          else
            FileUtils.mkdir_p(target_file, options)
          end
        end
        files.select {|item| ! File.directory?(item)}.each do |file|
          target_file = File.join(target, file)
          if File.exists?(target_file)
            puts "Info: not installing #{file}, it already exists in #{target}/#{file}" if verbose
          else
            FileUtils.install(file, target_file, options)
          end
        end
      end

    end

  end

end
