require 'rake/testtask'
require 'rake/rdoctask'

namespace :test do
  desc "run the design test suite"
  task :design do
    Rake::TestTask.new(:mt_test) do |t|
      t.libs << File.join(File.dirname(__FILE__), '/../lib')
      t.pattern = File.join(File.dirname(__FILE__), '/../test/**/*_test.rb')
      t.verbose = true
    end
    Rake::Task[:mt_test].invoke
  end
end

namespace :doc do
  desc "generate the design rdoc files"
  task :design do
    Rake::RDocTask.new(:mt_rdoc) do |rdoc|
      rdoc.rdoc_dir = File.join(File.dirname(__FILE__), '/../rdoc')
      rdoc.title    = 'Design'
      rdoc.options << '--line-numbers' << '--inline-source'
      rdoc.rdoc_files.include(File.join(File.dirname(__FILE__), '/../README'))
      rdoc.rdoc_files.include(File.join(File.dirname(__FILE__), '/../lib/**/*.rb'))
    end
    Rake::Task[:mt_rdoc].invoke
  end
end


 
