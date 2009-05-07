module Design

  # A design is composed of one or more boxes. Each box defines an area in the
  # screen identified by a number and possibly by a name. A box contains inside
  # it several Block objects, and is owner by some other object, possibly one
  # from the application model.
  class Box < ActiveRecord::Base

    set_table_name 'design_boxes'

    has_many :blocks, :class_name => Design::Block.name, :dependent => :destroy
    belongs_to :owner, :polymorphic => true
  
    validates_presence_of :owner_id
    validates_presence_of :owner_type
  
    #we cannot have two boxs with the same number to the same owner
    validates_uniqueness_of :number, :scope => [:owner_type, :owner_id]
  
    #<tt>number</tt> could not be nil and must be an integer
    validates_numericality_of :number, :only_integer => true

    before_validation_on_create  do |box|
      unless box.owner.nil?
        n_boxes = box.owner.boxes.count
        box.number ||= n_boxes + 1 
      end
    end

    # Return all blocks of the current box object sorted by the position block
    def blocks_sort_by_position
      self.blocks.sort{|x,y| x.position <=> y.position}
    end
 
   
  end
end
