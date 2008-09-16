module Design

  class FixedDesignHolder
    @@design_root = ''
    @@public_filesystem_root = ''

    attr_reader :template, :theme, :icon_theme, :boxes
    def initialize(options = {})
      @template = options[:template] || 'default'
      @theme = options[:theme] || 'default'
      @icon_theme = options[:icon_theme] || 'default'
      @@design_root = options[:root] || 'designs' 
      @@public_filesystem_root = options[:filesystem]  || File.join(RAILS_ROOT, 'public')
      @boxes = options[:boxes] || default_boxes
    end

   def self.design_root
     @@design_root
   end
   
   def self.public_filesystem_root
     @@public_filesystem_root
   end

    def maximum_number_of_boxes
      Design::Template.find(self.template).number_of_boxes
    end

    def displayable_boxes(reload = false)
      self.boxes.first(self.maximum_number_of_boxes)
    end

    def blocks
      boxes.map {|item| item.blocks}.flatten
    end
  
    # creates some default boxes
    def default_boxes
      box1 = Box.new
      box2 = Box.new
      box2.blocks << MainBlock.new
      box3 = Box.new
  
      [box1, box2, box3]
    end
    private :default_boxes
  end

end

