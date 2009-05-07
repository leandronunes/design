require File.dirname(__FILE__) + '/test_helper'

class BlockTest < Test::Unit::TestCase
  include Design

  def setup
    @owner = DesignTestModel.create!(:name => 'my test user')
    @box = Box.create!({:owner => @owner})
  end


  def test_should_have_box
    b = Block.new

    assert !b.valid?
    assert b.errors.invalid?(:box_id)
  end

  def test_should_position_be_a_integer
    b = Block.new
    b.position= 1
    b.valid?
    assert !b.errors.invalid?(:position)

    b.position= 1.1
    assert !b.valid?
    assert b.errors.invalid?(:position)

    b.position= 'test'
    assert !b.valid?
    assert b.errors.invalid?(:position)
  end

  def test_should_have_a_position
    b = Block.new
    assert !b.valid?
    assert b.errors.invalid?(:position)

    b.position=1
    b.valid?
    assert !b.errors.invalid?(:position)
  end

  def test_should_position_be_unique_on_scope
    b1 = create_block(:box_id => @box.id)
    b2 = Block.new(:position => b1.position, :box_id => @box.id )
    b2.valid?
    assert_not_equal b2.position, b1.position

    b3 = Block.new(:position => b1.position, :box_id => 1000  )
    b3.valid?
    assert !b3.errors.invalid?(:position)
    assert_equal b3.position, b1.position
  end

  def test_should_position_be_defined_on_creation
    b = Block.new(:position => nil, :box => @box)
    assert_nil b.position
    assert b.save
    assert_not_nil b.position
  end

  def test_should_settings_be_a_hash
    b = Block.new
    assert_kind_of Hash, b.settings
  end

  def test_should_display_title
    b = Block.new
    assert b.display_title
  end

  def test_should_display_title?
    b = Block.new
    b.display_title = false
    assert !b.display_title?

    b.display_title = true
    assert b.display_title?
  end

  def test_should_display_title=
    b = create_block
    b.display_title=false
    b.save
    b.reload
    assert !b.display_title?

    b.display_title= true
    b.save
    b.reload
    assert b.display_title?
  end

  def test_should_display_header
    b = Block.new
    assert b.display_header
  end

  def test_should_display_header?
    b = Block.new
    b.display_header = false
    assert !b.display_header?

    b.display_header = true
    assert b.display_header?
  end

  def test_should_display_header=
    b = create_block
    b.display_header=false
    b.save
    b.reload
    assert !b.display_header?

    b.display_header= true
    b.save
    b.reload
    assert b.display_header?
  end


  def test_main_should_always_return_false
    assert_equal false, Block.new.main?
  end

  private

  def create_block(params = {})
    Block.create!({:box_id => 1, :position => 1}.merge(params))
  end

end
