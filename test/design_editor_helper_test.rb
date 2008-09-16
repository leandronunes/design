require File.join(File.dirname(__FILE__), 'test_helper')

class DesignEditorHelperTestController < ActionController::Base

  self.template_root = File.join(File.dirname(__FILE__), 'views')
  layout 'design_editor_test'
  design_editor :holder => 'sample_object', :autosave => true
  def initialize
    Design.public_filesystem_root = File.dirname(__FILE__)
    @sample_object = DesignTestUser.new(:name => 'Some name')
    @sample_object.template = 'another'
    @sample_object.theme = 'default'
    @sample_object.icon_theme = 'default'
    @sample_object.save!
    Design::Box.delete_all
    Design::Block.delete_all
    box1 = Design::Box.new(:name => 'Box 1')
    box1.owner = @sample_object
    box1.save!
    design_test_block = DesignTestBlock.new(:position => 1)
    design_test_block.box = box1
    design_test_block.name = 'Design Test block' 
    design_test_block.save!
    box2 = Design::Box.new(:name => 'Box 2')
    box2.owner = @sample_object
    box2.save!
    main_block = Design::MainBlock.new(:position => 1)
    main_block.box = box2
    main_block.name = 'Main block'
    main_block.save!
    box3 = Design::Box.new(:name => 'Box 3')
    box3.owner = @sample_object
    box3.save!
    @sample_object.boxes = [ box1, box2, box3 ]

    #Create a new box and blocks to another controller
    @another_sample_object = DesignTestUser.new(:name => 'Another Some name')
    @another_sample_object.template = 'default'
    @another_sample_object.theme = 'default'
    @another_sample_object.icon_theme = 'default'
    @another_sample_object.save!
    box4 = Design::Box.new(:name => 'Box 1')
    box4.owner = @sample_object
    box4.save!

    design_test_block_2 = DesignTestBlock.new(:position => 1)
    design_test_block_2.box = box4
    design_test_block_2.name = 'Design Test block' 
    design_test_block_2.save!
    @another_sample_object.boxes = [ box1, box2, box3 ]


  end
  
  def index
    render :inline => '<%= design_display("my content") %>'
  end

  def display_editor
    render :inline => '<%= design_display_editor("Something")%>'
  end

end

class DesignEditorHelperTest < Test::Unit::TestCase

  def setup
    @controller = DesignEditorHelperTestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    Design.public_filesystem_root = File.dirname(__FILE__)
  end

  def teardown
    Design.public_filesystem_root = nil
  end

  def test_select_template_in_display_editor
    get :display_editor
    assert_tag :tag => 'a', :attributes => {
      :href => /design_editor_change_template/
    }
  end

  def test_select_theme_in_display_editor
    get :display_editor
    assert_tag :tag => 'a', :attributes => {
      :href => /design_editor_change_theme/
    }
  end

  def test_select_icon_theme_in_display_editor
    get :display_editor
    assert_tag :tag => 'a', :attributes => {
      :href => /design_editor_change_icon_theme/
    }
  end

  def test_should_render_the_right_number_of_boxes_in_display_editor
    get :display_editor
    #The number of boxes defined to the controller holder is 3 
    #but another template has only 2 boxes defined.
    #So only 2 boxes are draw
    assert_equal 2, assigns(:sample_object).displayable_boxes.length
    assigns(:sample_object).displayable_boxes.each do |box|
      assert_tag :tag => 'div', :attributes => { :id => "box_#{box.id}" }
    end
  end

  def test_should_make_blocks_draggable
    get :display_editor
    assigns(:sample_object).blocks.each do |block|
      assert_tag :tag => 'script',
        :content => /new Draggable\("block_#{block.id}", \{ghosting:false, revert:true\}\)/,
        :attributes => { :type => 'text/javascript' }
    end
  end

  def test_should_make_boxes_droppable
    get :display_editor
    assigns(:sample_object).displayable_boxes.each do |box|
      assert_tag :tag => 'script',
        :content =>  /Droppables.add\(\"box_#{box.id}\"/,
        :attributes => { :type => 'text/javascript' }
    end
  end

  def test_destroy_block
    count = Design::Block.find(:all).length
    get :design_editor_destroy_block, :block_id => 1
    assert count - 1, Design::Block.find(:all).length
  end

  def test_block_html_after_destroy_block
    get :design_editor_destroy_block, :block_id => 1
    assert_no_tag :tag => 'li', :attributes => {:id => 'block_1'}
  end

  def test_destroy_a_block_of_another_owner
    count = Design::Block.find(:all).length
    get :design_editor_destroy_block, :block_id => 3
    assert count, Design::Block.find(:all).length
  end

#TODO test the sort

#TODO test change element between boxes

end
