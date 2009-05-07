module Design

  # Box ix the base class for most of the content elements. A Box is contaied
  # by a Block, which may contain several blocks.
  class Block < ActiveRecord::Base

    set_table_name 'design_blocks'

    belongs_to :box

    belongs_to :box, :class_name => "Design::Box", :foreign_key => :box_id 
  
    #<tt>position</tt> could not be nil and must be an integer
    validates_numericality_of :position, :only_integer => true

    #<tt>position</tt> could not repeat
    validates_uniqueness_of :position, :scope => 'box_id'

    # A block must be associated to a box
    validates_presence_of :box_id 

    # when creating a new block, automatically assign a new position
    before_validation_on_create do |block|
      unless block.box.nil?
        block.position = (block.box.blocks.maximum(:position) || 0) + 1
      end
    end

    serialize :settings, Hash

    def self.description
      raise "You have to overwrite me"
    end

    # Initialize settings as Hash
    def initialize(*args)
      super(*args)  
      self.settings ||= {}
    end

    # This method always return false excepted when redefined by the MainBlock class. It mean the current block it's not the result of a
    # controller action.
    #
    # The child class MainBlock subscribes this method returning true.
    def main?
      false
    end

    # Return true if the title will be displayed on page or
    # false in the other case.
    #
    # The default value is true
    def display_title
      self.settings[:display_title] ||= 'true'
    end  

    def display_title?
      self.display_title == 'false' ? false : true
    end  

    def display_title= value
      self.settings[:display_title] =  value.to_s == 'true' ? 'true' : 'false'
    end  

    # Return true if the headr will be displayed on page or
    # false in the other case.
    #
    # The default value is false
    def display_header
      self.settings[:display_header] ||= 'false'
    end  
    def display_header?
      self.display_header == 'false' ? false : true
    end  

    def display_header= value
      self.settings[:display_header] =  value.to_s == 'true' ? 'true' : 'false'
    end  

    #FIXME make this test
    # Returns the name of the controller associated with the block
    # EX:
    #   BlockName
    def controller_name
      self.class.name.pluralize
    end

    #FIXME make this test
    # Returns the full name of the controller associated with the block
    # EX:
    #   BlockNameController
    def controller_full_name
      self.class.name.pluralize + 'Controller'
    end
  
    def member_link(action = nil)
      "#{action.nil? ? '' : action + '_'}#{self.class.name.underscore}_path"
    end 

  end

end # END OF module Design
