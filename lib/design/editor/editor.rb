module Design

  # This module contains the functionality for e design editor.
  module Editor

    def design_editor
      if request.post?
        design_editor_set_template
        design_editor_set_theme
        design_editor_set_icon_theme

        if self.class.design_plugin_config[:autosave] && design_interface.respond_to?(:save)
          design_interface.save
        end

        if request.xhr?
          render :nothing => true
        else
          redirect_to :action => params[:destiny_action] || 'design_editor'
        end

      else
        design_editor_render_local
      end
    end

    # Return a hash with the block type information passed by application. The hash must have
    # the key as constant Design::Block names and the value like the name of the block
    # Ex:
    # {
    #   'TheBlock' => _('The Block')
    #   'SomeBlock' => _('Some Block')
    # }
    def design_editor_block_types
      data = self.class.design_plugin_config[:block_types]
      raise "You must have blocks defined on your controller. See the documentation for more information" if data.nil?
      if data.kind_of? Symbol  
        block_types = self.send(data)
      elsif data.kind_of? Hash
        block_types = data
      else
        block_types = Hash.new
      end

#TODO see if it's needed
#      raise "You have a wrong block definition on %s" % block_types.inspect unless check_block_types(block_types)

      block_types.reject!{|k,v| k == 'MainBlock' or k == 'Design::MainBlock'} 

      block_types #making the result method more clear
    end

#TODO see if it's needed to check the blocks
#    def check_block_types(block_types)
#      return false unless block_types.kind_of?(Array)
#      are_blocks = block_types.all? do |b|
#        b.constantize.superclass == Design::Block
#      end
#
#      are_blocks #making the result method more clear
#    end

    def design_editor_add_block
      block = params[:type].constantize.new
      @box = design_content.default_box
      @box.blocks<< block
      block.save!
      #FIXME The called to the method bellow it's not working so I replace it for the
      # render :update method.
      #
      # design_editor_render_local_js
      render :update do |page|
        page.replace(design_id_for_box(@box), design_editor_box(@box))
        page.replace('design_editor_make_sortable', design_editor_make_sortable)
      end
    end

    def design_editor_edit_block
      @block = Block.find(params[:block_id])
      design_editor_render_local_js
    end

    def design_editor_update_block
      b = design_content.blocks.find(params[:block_id])
      b.update_atrributes(params[:block])
    end

    # saves the block order
    def design_editor_set_blocks_order
      design_content.boxes.map do |box|
        next if params["design_blocks_#{box.id}"].nil?

        params["design_blocks_#{box.id}"].each_with_index do |block_id,position|
          begin
            block = Design::Block.find(block_id.gsub('block_',''))
          rescue
            next
          end
          block.position = position + 1
          box.blocks<< block
        end
      end
      render :nothing => true
    end

    def design_editor_change_template
      @templates = Design::Template.all
      design_editor_render_local
    end

    def design_editor_change_theme
      @themes = Design::Theme.all
      design_editor_render_local
    end

    def design_editor_change_icon_theme
      @icon_themes = Design::IconTheme.all
      design_editor_render_local
    end

    # Set to the owner the template choosed
    def design_editor_set_template
      if design_editor_exists_template?(params[:template])
        design_interface.template = params[:template]
        design_interface.save if self.class.design_plugin_config[:autosave] && design_interface.respond_to?(:save)
      end
      redirect_to :action => 'design_editor_change_template'
    end

    # Set to the owner the theme choosed
    def design_editor_set_theme
      if design_editor_exists_theme?(params[:theme])
        design_interface.theme = params[:theme]
        design_interface.save if self.class.design_plugin_config[:autosave] && design_interface.respond_to?(:save)
      end
      redirect_to :action => 'design_editor_change_theme'
    end

    # Set to the owner the icon_theme choosed
    def design_editor_set_icon_theme
      if design_editor_exists_icon_theme?(params[:icon_theme])
        design_interface.icon_theme = params[:icon_theme]
        design_interface.save if self.class.design_plugin_config[:autosave] && design_interface.respond_to?(:save)
      end
      redirect_to :action => 'design_editor_change_icon_theme'
    end

    private 

    def design_editor_render_local(extension = 'html', layout = true)
      view_path = File.join(RAILS_ROOT, 'app', 'views', params[:controller], params[:action] + '.rhtml')
      if File.exists?(view_path)
        render :file => view_path, :layout => layout
      else
        render :file => File.join(File.dirname(__FILE__), '..', '..', '..', 'views', 'design_editor', params[:action] + '.' + extension + '.erb'), :layout => layout
      end
    end

    def design_editor_render_local_js
      design_editor_render_local('js', false)
    end

    #check if a given template exists on set of templates 
    def design_editor_exists_template?(template)
      DesignConfiguration.available_templates.include?(template)
    end

    #check if a given theme exists on set of theme
    def design_editor_exists_theme?(theme)
      DesignConfiguration.available_themes.include?(theme)
    end

    #check if a given icon theme exists on set of icon theme
    def design_editor_exists_icon_theme?(icon_theme)
      DesignConfiguration.available_icon_themes.include?(icon_theme)
    end

  end

end
