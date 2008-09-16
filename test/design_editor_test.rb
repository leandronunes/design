require File.join(File.dirname(__FILE__), 'test_helper')

class DesignEditorTestController; def rescue_action(e) raise e end; end

class DesignEditorTest < Test::Unit::TestCase

  def setup
    @controller = DesignEditorTestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    Design.public_filesystem_root = File.join(File.dirname(__FILE__))
  end

  def teardown
    Design.public_filesystem_root = nil
  end

  def test_should_render_design_in_editor_mode
    get :design_editor
    assert_response :success
    assert_template 'design_editor.rhtml'
  end

  def test_should_set_new_template
    assert_equal 'default', @controller.send(:design).template
    post :design_editor, :template => 'empty'
    assert_response :redirect
    assert_redirected_to :action => 'design_editor'
    assert_equal 'empty', @controller.send(:design).template
    assert @controller.send(:design).saved?
  end

  def test_should_not_set_to_unexisting_template
    assert_equal 'default', @controller.send(:design).template
    post :design_editor, :template => 'no_existing_template'
    assert_response :redirect
    assert_redirected_to :action => 'design_editor'
    assert_equal 'default', @controller.send(:design).template
    assert @controller.send(:design).saved?
  end


  def test_should_set_new_theme
    assert_equal 'default', @controller.send(:design).theme
    post :design_editor, :theme => 'empty'
    assert_response :redirect
    assert_redirected_to :action => 'design_editor'
    assert_equal 'empty', @controller.send(:design).theme
    assert @controller.send(:design).saved?
  end

  def test_should_not_set_to_unexisting_theme
    assert_equal 'default', @controller.send(:design).theme
    post :design_editor, :theme => 'no_existing_theme'
    assert_response :redirect
    assert_redirected_to :action => 'design_editor'
    assert_equal 'default', @controller.send(:design).theme
    assert @controller.send(:design).saved?
  end

  def test_should_set_new_icon_theme
    assert_equal 'default', @controller.send(:design).icon_theme
    post :design_editor, :icon_theme => 'empty'
    assert_response :redirect
    assert_redirected_to :action => 'design_editor'
    assert_equal 'empty', @controller.send(:design).icon_theme
    assert @controller.send(:design).saved?
  end

  def test_should_not_set_to_unexisting_icon_theme
    assert_equal 'default', @controller.send(:design).icon_theme
    post :design_editor, :icon_theme => 'no_existing_icon_theme'
    assert_response :redirect
    assert_redirected_to :action => 'design_editor'
    assert_equal 'default', @controller.send(:design).icon_theme
    assert @controller.send(:design).saved?
  end

  def test_should_add_a_new_block_with_the_right_class
    Design::Box.delete_all
    Design::Block.delete_all

    user = DesignTestUser.create!(:name => 'bli')
    @controller.stubs(:design).returns(user)

    assert @controller.send(:design).boxes.create(:name => 'test block', :owner_id => 1, :number => 1)

    post :design_editor_add_block, :block => { :title => 'a test block', :position => '1' }, :box_id => Design::Box.find(:first).id.to_s, :type => Design::MainBlock.name
    assert_response :redirect
    assert_redirected_to :action => 'design_editor'
    assert_equal 1, Design::Block.count
    assert_kind_of Design::MainBlock, Design::Block.find(:first)
  end

  def test_should_return_error_code_when_failed_to_create_block
    post :design_editor_add_block, :block => { :type => Design::MainBlock.name }
    #assert_response 403
    assert_tag :tag => 'div', :attributes => { :class => 'errorExplanation' }
  end

  def test_should_save_blocks_order

    design = DesignTestUser.create!(:name => 'test virtual community')
    box = design.boxes.first
    block1 = box.blocks.create(:position => 1, :name => 'one')
    block2 = box.blocks.create(:position => 2, :name => 'two')
    assert block1.save
    assert block2.save

    @controller.expects(:design).returns(design)

    post :design_editor_set_blocks_order, :box_id => box.id, :blocks_box_1 => [ '2', '1' ]

    assert_response :success
    assert_equal 2, box.blocks.find(block1.id).position
    assert_equal 1, box.blocks.find(block2.id).position


  end

  def test_should_be_able_to_move_block_from_one_box_to_another
    design = DesignTestUser.create!(:name => 'test stuff')
    box1 = design.boxes[0]
    box2 = design.boxes[1]
    block1 = box1.blocks.create(:position => 1, :name => 'one')
    assert block1.save

    @controller.stubs(:design).returns(design)

    post :design_editor_move_block, :block_id => block1.id, :id => "box_#{box2.id}"

    # moved from box1 to box2
    assert_equal box2, design.blocks.find(block1.id).box
  end



end
