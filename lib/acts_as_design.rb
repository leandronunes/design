
module Design

   module ActsAsDesign

    # declares an ActiveRecord class to be a design. The class is automatically
    # associated with a +has_many+ relationship to Design::Box.
    #
    # The underlying database table *must* have a column named +design_data+ of
    # type +text+. +string+ should work too, but you may run into problems
    # related to length limit, so unless you have a very good reason not to, use
    # +text+ type.
    #
    # +acts_as_design+ adds the following methods to your model (besides a
    # +has_many :boxes+ relationship).
    #
    # * template
    # * template=(value)
    # * theme
    # * theme=(value)
    # * icon_theme
    # * icon_theme(value)
    #
    # All these virtual attributes will return <tt>'default'</tt> if set to +nil+

    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods
      def acts_as_design(config = {})
        send :include, InstanceMethods
        
  #      @design_root = config[:root]
  #      @public_filesystem_root = config[:filesystem]
  #      DesignConfiguration.design_root = @design_root if DesignConfiguration.design_root_default == DesignConfiguration.design_root
  #  
  #      DesignConfiguration.public_filesystem_root = @public_filesystem_root
  #  
        has_many :boxes, :class_name => Design::Box.name, :as => :owner, :dependent => :destroy

        serialize :design_data

        before_save do |design|
          template = Design::Template.find(design.template)
          while design.boxes.size < template.number_of_boxes
            n = design.boxes.size + 1
            design.boxes << Design::Box.new(:name => "Box %s" % n, :number => n)
          end
        end
  
        after_create do |design|
          d = Design::MainBlock.new
          design.boxes.first.blocks << d
        end
  #
  #      def self.design_root
  #        @design_root
  #      end
  #
  #      def self.public_filesystem_root
  #        @public_filesystem_root
  #      end
      end
    end

    module InstanceMethods

      def initialize(*args)
        super(*args)
        self.design_data ||= Hash.new
      end

      def template
        self.design_data[:template] || 'default'
      end

      def template=(value) # :nodoc:
        self.design_data[:template] = value
      end

      def theme # :nodoc:
        self.design_data[:theme] || 'default'
      end

      def theme=(value) # :nodoc:
        self.design_data[:theme] = value
      end

      def icon_theme # :nodoc:
        self.design_data[:icon_theme] || 'default'
      end

      def icon_theme=(value) # :nodoc:
        self.design_data[:icon_theme] = value
      end

      def default_box
        self.boxes.find(:first)
      end

      def default_box_number
        default_box.number
      end

      #Return the maximum number of boxes in the current object template
      def maximum_number_of_boxes
        Design::Template.find(self.template).number_of_boxes
      end

      def displayable_boxes(reload = false)
        self.boxes(reload).first(self.maximum_number_of_boxes)
      end

      def blocks(reload = false)
        if reload || @blocks.nil?
          @blocks = self.displayable_boxes(reload).map { |item| item.blocks }.flatten
          def @blocks.find(the_id)
            select {|item| item.id == the_id.to_i}.first
          end
        end
        @blocks
      end

    end

  end

end

ActiveRecord::Base.send :include, Design::ActsAsDesign
