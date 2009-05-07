#require 'design/editor'

module Design

  module ControllerMethods

    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods

      # Declares that this controller uses design plugin to generate its layout.
      # See the plugin README for options that can be passed to this method.
      def design(config = {})
        send :include, InstanceMethods

        helper Design::Helper
        require 'design/block_helper'
        helper Design::Helper::Block


#        helper Design::Helper::Block


        raise ArgumentError.new("design argument must be a Hash") unless config.kind_of? Hash

        if (!config.has_key?(:holder) && !config.has_key?(:fixed) && !config.has_key?(:interface_holder))
          raise ArgumentError.new("You must supply either <tt>:holder</tt> or <tt>:fixed</tt> or <tt>:interface_holder</tt> to design.")
        end

        @design_plugin_config = config

        def design_plugin_config
          @design_plugin_config || self.superclass.design_plugin_config
        end

      end

      # declares this controller as a design editor, including in it all the
      # functionalities to do that (besides those for using a design). Accepts the
      # same options as design.
      def design_editor(config = {})
        require 'design/editor/editor'
        require 'design/editor/helper'
        design(config)
        send :include, Design::Editor
        helper Design::Editor::Helper
      end

    end

    module InstanceMethods

      def design_plugin_data
        @design_plugin_data ||= Hash.new
      end

      # gets the Design object for this controller
      def design
        data = design_plugin_data

        return data[:design] if data.has_key?(:design)

        config = self.class.design_plugin_config

        #FIXME make unit and functional tests for this option.
        # Now users could set actions where the holder is valid.
        show_current_action = true
        only_actions = config[:only] || []
        except_actions = config[:except] || []
        if only_actions.blank?
          show_current_action = (not except_actions.include?(params[:action].to_sym)) unless except_actions.blank?
        else
          show_current_action = only_actions.include?(params[:action].to_sym)
        end

        if config[:fixed].kind_of? Hash and show_current_action
          
          options = config[:fixed] || {}
          design_holder = Design::FixedDesignHolder.new(options)
          content_holder = interface_holder = design_holder
        elsif show_current_action
          content_holder_name = config[:content_holder] || config[:holder] 
          if content_holder_name.kind_of? Symbol
            content_holder = self.send(content_holder_name)
          else
            content_holder = self.instance_variable_get("@#{content_holder_name}")
          end

          interface_holder_name = config[:interface_holder] || config[:holder] 
          if interface_holder_name.kind_of? Symbol
            interface_holder = self.send(interface_holder_name)
          else
            interface_holder = self.instance_variable_get("@#{interface_holder_name}")
          end
        end

        raise "You must have at least the interface defined" if interface_holder.blank?

        data[:design] = DesignHolder.new(interface_holder, content_holder)

        DesignConfiguration.set_default_config(data[:design])
 
        data[:design]  #redundant, but makes more clear the return value
      end

      def design_interface
        design.interface
      end

      def design_content
        design.content
      end

      protected :design, :design_interface

    end

  end

end

ActionController::Base.send :include, Design::ControllerMethods
