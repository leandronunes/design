module Design

  # Block subclass to represent blocks that must contain the main content, i.e.
  # the result of the controller action, or yet, the value you would get by
  # calling +yield+ inside a regular view.
  class MainBlock < Design::Block

    # always returns true
    def main?
      true
    end
    
#    def validate
#      unless self.box.nil?
#        self.errors.add(_("You already have the Main Block")) if self.box.owner.blocks.detect{|b| b.class == Design::MainBlock}
#      end
#    end
 
  end

end
