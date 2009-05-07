#FIXME Review This

module Design
  module ActsAsDesignBlock

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def acts_as_design_block(config = {})
        send :include, InstanceMethods
  #FIXME remove this is it's not needed
  #      include Design
  #      helper Design::BlockHelper
        helper Design::Editor::Helper
        helper Design::Editor::BlockHelper


        before_filter :design_load_block
      end    

    end

    module InstanceMethods

      def design_load_block
        @design_block = design_content.blocks.find(params[:block_id]||params[:id])
        raise "block cannot be loaded to design %s with parameter %s" % [design_content.inspect, params[:block_id]||params[:id]] if @design_block.nil?
      end

      #FIXME make this test
      def destroy
        raise "This block cannot be removed" unless @design_block.destroy
        render :nothing => true
      end

      def design_render(options = {})
        file_path = design_calculate_view_path(options)
        if request.xml_http_request?
          @action_content =  options[:nothing] == true ? nil : render_to_string(:file => file_path)

  #FIXME see why this informations cannot be on the rjs file because it didn't works
  #The file views/design_block/render_action.rjs has the same information that the 
  #render :update bellow but it's not working
  #        render :file => File.join(File.dirname(__FILE__), '..', 'views', 'design_block','render_action' + '.rjs')
          render :update do |page|
            page.replace_html(design_id_for_block_content(@design_block), 
              design_block_content_core(@design_block, @action_content)
            )
          end
        else
          render :file => file_path
        end
      end

      def design_render_on_edit(options = {})
        file_path = design_calculate_view_path(options)
        if request.xml_http_request?
          @action_content =  options[:nothing] == true ? nil : render_to_string(:file => file_path)
          render :update do |page|
            page.replace_html(design_id_for_block(@design_block), 
              design_editor_block_core(@design_block, @action_content)
            )
          end
        else
          raise 'You cannot have non xml_http_request actions editing blocks'
        end
      end

      private

      def design_calculate_view_path(options = {})
        params.merge!(options) 
        local_file_path =  File.join(DesignConfiguration.design_blocks_root, params[:controller], 'views', "#{params[:action]}" + '.rhtml')
        plugin_file_path = File.join(RAILS_ROOT, 'vendor', 'plugins', 'design', 'views', 'design_block', params[:action] + '.rhtml')
        if File.exists?(local_file_path)
          file_path = local_file_path
        elsif File.exists?(plugin_file_path)
          file_path = plugin_file_path
        else
          file_path = local_file_path
        end
       
      end

    end

  end

end

ActionController::Base.send :include, Design::ActsAsDesignBlock
