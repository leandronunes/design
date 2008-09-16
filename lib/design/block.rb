module Design

  # Box ix the base class for most of the content elements. A Box is contaied
  # by a Block, which may contain several blocks.
  class Block < ActiveRecord::Base

    set_table_name 'design_blocks'

    belongs_to :box
  
    #<tt>position</tt> codl not be nil and must be an integer
    validates_numericality_of :position, :only_integer => true

    # A block must be associated to a box
    validates_presence_of :box_id 

    # when creating a new block, automatically assign a new position
    before_validation_on_create do |block|
      unless block.box.nil?
        block.position = (block.box.blocks.map(&:position).max || 0) + 1
      end
    end

    serialize :settings, Hash

    def settings
      self[:settings] ||= {}
    end

    def self.description
      raise "You have to overwrite me"
    end

    # FIXME See why this code didn't works.
    # If this method works we can erase the settings method defined on this class
#    def initialize(*args)
#      super(*args)  
#      self[:settings] ||= {}
#    end

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
      self.settings[:display_title] ||= 'false' 
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

  end

end # END OF module Design
