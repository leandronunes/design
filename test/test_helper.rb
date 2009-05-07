ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '/../../../..'
require File.expand_path(File.join(ENV['RAILS_ROOT'], 'config/environment.rb'))

ENV["RAILS_ENV"] = "test"
require 'test_help'

def load_schema
  config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
  ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")

  db_adapter = ENV['DB']

  # no db passed, try one of these fine config-free DBs before bombing.
  db_adapter ||=
    begin
      require 'rubygems'
      require 'sqlite'
      'sqlite'
    rescue MissingSourceFile
      begin
        require 'sqlite3'
        'sqlite3'
      rescue MissingSourceFile
      end
    end

  if db_adapter.nil?
    raise "No DB Adapter selected. Pass the DB= option to pick one, or install Sqlite or Sqlite3."
  end

  ActiveRecord::Base.establish_connection(config[db_adapter])
  load(File.dirname(__FILE__) + "/schema.rb")
  require File.dirname(__FILE__) + '/../init.rb'
end

load_schema

# Change the table names for the tests to not touch 
# on application tables
Design::Box.set_table_name 'design_test_design_boxes'
[Design::Block, Design::MainBlock].each do |item|
  item.set_table_name 'design_test_design_blocks'
end

# example class to hold some blocks
class DesignTestModel < ActiveRecord::Base
  set_table_name 'design_test_users'

  acts_as_design :filesystem => File.dirname(__FILE__)

end

#########################
## test clases below here
#########################
#
#class FixedDesignTestController < ActionController::Base
#
#  BOX1 = Design::Box.new
#  BOX2 = Design::Box.new
#  BOX2.blocks << Design::MainBlock.new
#  BOX3 = Design::Box.new
#
#  design :fixed => {
#    :template => 'some_template',
#    :theme => 'some_theme',
#    :icon_theme => 'some_icon_theme',
#    :boxes => [ BOX1, BOX2, BOX3 ],
#  }
#end
#
#class FixedDesignDefaultTestController < ActionController::Base
#  design :fixed => true
#end
#
#class SampleHolderForTestingProxyDesignHolder 
#
#  attr_accessor :template, :theme, :icon_theme, :boxes
#  def initialize
#    @saved = false
#  end
#  def save
#    @saved = true
#  end
#  def saved?
#    @saved
#  end
#
#  def self.design_root
#    'designs'
#  end
#
#  def self.public_filesystem_root
#    File.dirname(__FILE__)
#  end
#
#  def maximum_number_of_boxes
#    Design::Template.find(self.template).number_of_boxes
#  end
#
#  def displayable_boxes
#    self.boxes.first(self.maximum_number_of_boxes)
#  end
#
#end
#
#class ProxyDesignHolderTestController < ActionController::Base
#  design :holder => 'sample_object'
#  def initialize
#    @sample_object = SampleHolderForTestingProxyDesignHolder.new
#  end
#end
#
#class AnotherTestDesignHolder
#  attr_accessor :template, :theme, :icon_theme, :boxes
#end
#
#class InheritanceWithOverrideDesignTestController < ProxyDesignHolderTestController
#  design :holder => 'another_object'
#end
#
#class InheritanceDesignTestController < ProxyDesignHolderTestController
#  # nothing
#end
#
#class DesignEditorTestController < ActionController::Base
#
#  self.template_root = File.join(File.dirname(__FILE__), 'views')
#  layout 'design_editor_test'
#  design_editor :holder => 'sample_object', :autosave => true
#  def initialize
#    @sample_object = SampleHolderForTestingProxyDesignHolder.new
#    @sample_object.template = 'default'
#    @sample_object.theme = 'default'
#    @sample_object.icon_theme = 'default'
#    def @sample_object.id
#      1
#    end
#
#    box1 = Design::Box.new(:number => 1)
#    box2 = Design::Box.new(:number => 2)
#    main_block = Design::MainBlock.new(:position => 1)
#    box2.blocks << main_block
#    main_block.box = box2
#    main_block.name = 'Main block'
#    box3 = Design::Box.new(:number => 3)
#    @sample_object.boxes = [ box1, box2, box3 ]
#  end
#end
#
#class DesignTestBlock < Design::Block
#  def content
#    DesignTestUser.find(:all).map{|u|u.name}
#  end
#end

