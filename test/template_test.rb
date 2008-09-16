require File.dirname(__FILE__) + '/test_helper'

class TemplateTest < Test::Unit::TestCase

  include Design

  def setup
    Design.public_filesystem_root = File.join(File.dirname(__FILE__))
  end
  def teardown
    Design.public_filesystem_root = nil
  end

  def test_should_read_title
    assert_equal 'Some title', Template.new('test', { 'title' => 'Some title' }).title
  end

  def test_should_get_name
    assert_equal 'default', Template.find('default').name
  end

  def test_template_whitout_yml_file
    assert_raise(RuntimeError){
      Template.find('empty').name
    }
  end

  def test_should_get_number_of_boxes
    assert_equal 3, Template.new('test', { 'number_of_boxes' => 3}).number_of_boxes
  end

  def test_should_list_all_templates
    assert(Template.all.all? do |template|
      template.kind_of? Template
    end)
  end

  def test_should_list_only_valid_templates
    templates_names =  Template.all.map {|item| item.name}
    assert templates_names.include?('default')
    assert templates_names.include?('another')
  end

end
