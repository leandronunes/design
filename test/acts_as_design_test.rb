require File.join(File.dirname(__FILE__), 'test_helper')

class ActsAsDesignTest < Test::Unit::TestCase

  def setup
    Design.public_filesystem_root = File.join(File.dirname(__FILE__))
  end

  def teardown
    Design.public_filesystem_root = nil
  end

  def test_should_provide_template_attribute
    user = DesignTestUser.new
    assert_equal 'default', user.template
    user.template = 'other'
    assert_equal 'other', user.template
    user.template = nil
    assert_equal 'default', user.template
  end
  
  def test_should_provide_theme_attribute
    user = DesignTestUser.new
    assert_equal 'default', user.theme
    user.theme = 'other'
    assert_equal 'other', user.theme
    user.theme = nil
    assert_equal 'default', user.theme
  end

  def test_should_provide_icon_theme_attribute
    user = DesignTestUser.new
    assert_equal 'default', user.icon_theme
    user.icon_theme = 'other'
    assert_equal 'other', user.icon_theme
    user.icon_theme = nil
    assert_equal 'default', user.icon_theme
  end

  def test_should_store_data_in_a_hash
    user = DesignTestUser.new
    assert_kind_of Hash, user.design_data
  end

  def test_should_provide_association_with_boxes
    user = DesignTestUser.new
    assert user.boxes << Design::Box.new
    assert_raise ActiveRecord::AssociationTypeMismatch do
      user.boxes << 1
    end
  end

  def test_should_accesses_blocks_through_boxes
    user = DesignTestUser.create!(:name => 'A test user')
    user.boxes.first.blocks << Design::Block.new
    assert_kind_of Array, user.blocks
    assert_equal 1, user.blocks.size
  end

  def test_should_be_able_to_find_in_blocks
    user = DesignTestUser.create!(:name => 'A test user')
    block = Design::Block.new(:position => 1)
    assert (user.boxes.first.blocks << block)
    assert_equal block, user.blocks.find(block.id)
    assert_equal block, user.blocks.find(block.id.to_s) # string must be accepted too
  end

  def test_should_create_boxes_when_creating

    DesignTestUser.delete_all
    Design::Box.delete_all

    user = DesignTestUser.create!(:name => 'A test user')
    # default template (test/designs/templates/default/default.yml) defines
    # 3 boxes
    assert_equal 3, Design::Template.find('default').number_of_boxes
    assert_equal 3, user.boxes.size
    assert_equal 3, Design::Box.count
  end

  def test_should_create_extra_boxes_when_changing_to_a_template_with_more_boxes
    DesignTestUser.delete_all
    Design::Box.delete_all

    user = DesignTestUser.create!(:name => 'A test user')
    assert_equal 3, user.boxes.size

    template = Design::Template.new('test', { 'number_of_boxes' => 4 })
    Design::Template.expects(:find).with('test').returns(template)
    user.template = 'test'
    assert user.save
    assert_equal 4, user.boxes(true).size

  end

  def test_should_provide_list_of_displayable_blocks
    DesignTestUser.delete_all
    Design::Template.stubs(:find).with('test_2_boxes').returns(Design::Template.new('test_2_boxes', { 'number_of_boxes' => 2 }))
    user = DesignTestUser.create!(:name => 'A test user', :template => 'test_2_boxes')
    assert user.boxes.create(:title => 'a test block')
    assert_equal 3, user.boxes.size
    assert_equal 2, user.displayable_boxes.size
  end

end
