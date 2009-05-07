module Design

  module Editor

    # defines helper methods for controllers that use +design_editor+
    module Helper
      # proxies calls to controller's design method to get the design information
      # block types object
      def design_editor_block_types
        @controller.send(:design_editor_block_types)
      end

      def design_display_editor(content = '')
        template = Design::Template.find(design_interface.template)
        design_editor_blocksbar +
        content_tag('div',
          design_editor_boxes(design_content.displayable_boxes.reverse, content),
          :id => 'design_editor'
        )
      end

      def design_editor_boxes(boxes, content = '')
        content_tag(:div,
          boxes.map { |item|
            design_editor_box(item, content)
          }.join("\n")+
          design_editor_make_sortable
        )
      end

      def design_editor_toolbar(params = {})
        content_tag(:ul, 
          [
            content_tag(:li, 
              link_to( 
                content_tag(:span, t(:label_change_template)), 
                params.merge(:action => 'design_editor_change_template'), 
                :id => 'design_change_template'
              ), 
              :class => 'design_change_item'
            ),
            content_tag(:li, 
              link_to( content_tag(:span, t(:label_change_block_theme)), 
                params.merge(:action => 'design_editor_change_theme'),
                :id => 'design_change_block_theme'
              ), 
              :class => 'design_change_item'
            ),
            content_tag(:li, 
              link_to( content_tag(:span, t(:label_change_icon_theme)), 
                params.merge(:action => 'design_editor_change_icon_theme'),
                :id => 'design_change_icon_theme'
              ), 
              :class => 'design_change_item'
            )
          ].join("\n"),
          {:id => 'design_change_list'}
        )
      end


      def design_editor_toolbar_full
        # Generate a list of block type links that update the box with number one with the block choosen
        block_types = design_editor_blocksbar
        links = design_editor_toolbar
        content_tag('div',
                    block_types +  content_tag(:h3, t(:label_toolbar)) + links,
                    :id => 'design_editor_toolbar')
      end

      def design_editor_blocksbar
        # Generate a list of block type links that update the box with number one with the block choosen
        content_tag(:ul,
          design_editor_block_types.map do |block|
            content_tag(:li, 
              link_to_remote(
                content_tag(:span, block.constantize.description ),  
                :url => {:action => 'design_editor_add_block', :type => block},
                :failure => "$('design_editor').innerHTML=request.responseText"
              ),
              {:id => "design_editor_blocksbar_item_#{block}", :class => 'design_editor_blocksbar_item'}
            )
          end.join("\n"),
          {:id => 'design_editor_blocksbar', :class => 'design_editor_blocksbar'}
        )
      end

      def design_editor_box(box, content = '')
        content_tag(
          'div',
          [
            design_editor_box_header(box),
            design_editor_blocks(box, content),  
          ].join("\n"),
          :class => 'design_box', :id => design_id_for_box(box)
        ) 
      end

      def design_editor_blocks(box, content = '')
        content_tag(:ul, 
          box.blocks_sort_by_position.map do |item| 
            design_editor_block(item, content) 
           end.join("\n"), 
          :class => 'design_blocks', :id => design_id_for_blocks(box)
        )
      end
    
      def design_editor_box_header(box)
#        content_tag('div', _('Area %s') % box.number, :class => 'design_box_header') #FIXME see what is better
        content_tag('div', '', :class => 'design_box_header')
      end

      def design_editor_block(block, content = '')
        content_tag('li', 
          design_editor_block_core(block, content),
          :id => design_id_for_block(block), :class => 'design_block'
        ) 
      end

      def design_editor_block_core(block, content = '')
        content_tag(:div, 
          [
            (block.main? ? '' : design_editor_block_header_full(block)),
            design_editor_block_content(block, content),
            design_editor_block_footer(block)
          ].join("\n"),
          :class => "design_block_type #{block.controller_name.underscore}"
        )
      end

      def design_editor_block_footer(block)
        content_tag(:div, '', :class => "design_block_footer", :id => design_id_for_block_footer(block) )
      end

      def design_editor_block_header_full(block)
        design_editor_block_controls(block) + 
        (block.controller_full_name.constantize.constants.include?('CONTROL_ACTION_OPTIONS') ?  design_editor_block_control_options(block) : '') +
        design_editor_block_header(block)
      end

      def design_editor_block_controls(block)
        content_tag(:ul,
          [
            block.class == Design::MainBlock ? nil :
            content_tag(:li,
              link_to_remote(
                content_tag(:span, t(:label_remove)),
#                content_tag(:span, block.controller_name.underscore + '_path'),
                {
#                  :url => params.merge({:controller => block.controller_name.underscore, :action => 'design_editor_destroy_block', :block_id => block.id }),
#                  :url => block.controller_name.underscore + '_path',
                  :url => self.send("#{block.class.name.underscore}_path",block),
#                  :url => admin_favorite_link_path(block),
#                  :url => favorite_link_path(block),
                  :success => visual_effect(:fade, design_id_for_block(block)),
                  :method => :delete,
                  :failure => "$('#{design_id_for_block(block)}').innerHTML= request.responseText" 
                },
                { :class => 'design_button_block button_block_remove' }
              )
            ),

           if block.controller_full_name.constantize.constants.include?('CONTROL_ACTION_OPTIONS')
             content_tag(:li,
                link_to_function(
                  content_tag(:span, t(:label_options) ),
                  {
                    :onclick => visual_effect(:toggle_appear, design_id_for_block_control_options(block), :duration => 0.6),
                    :class => 'design_button_block button_block_options' 
                  }
                )
              )
           else 
             ''
           end
          ].join("\n"),
          :class => 'design_block_control'
        )
      end

      def design_editor_block_control_options(block)
        content_tag(:div,
          content_tag(:div,
            content_tag(:ul,
              block.controller_full_name.constantize::CONTROL_ACTION_OPTIONS.map do |k,v|
                content_tag(:li,
                  link_to_remote(
                    content_tag(:span, v ),
                    {
#                      :url => params.merge({:controller => block.controller_name.underscore, :action => k, :block_id => block.id }),
#                      :url => self.send("#{k}_#{block.class.name.pluralize.underscore}_path",block),
                      :url => self.design_block_action_link(block, k),
                      :method => :get,
                      :failure => "$('#{design_id_for_block_content(block)}').innerHTML= request.responseText"
                    },
                    { :class => 'design_button_block button_block_item_options' }
                  )
                )
              end.join("\n"),
              :class => 'design_block_control_options'
            )
          ), 
          :id => design_id_for_block_control_options(block), :style => "display : none;" 
        )
      end

      #FIXME The block cannot have same actions as collection and member on 
      # CONTROL_ACTION_OPTIONS
      # EX: manage_links action and manage_link action
      # The system always call manage_links action
      def design_block_action_link(block, action = nil)
        self.send("#{block.member_link(action)}", block)
      end

      def design_editor_block_header(block)
        content_tag(:h3, block.title || t(:label_no_title),{:class => 'design_block_header', :id => design_id_for_block_header(block) } )
      end

      def design_editor_block_content(block, content = nil)
        content_tag(:div,
          content_tag(:div,
            block.main? ? 
            (t(:label_main_content)) :
            (content.blank? ? block.class.description : content)
          ),
          :id => design_id_for_block_content(block), :class => "design_block_content"
        )
      end

      def design_editor_make_sortable
        content_tag(:div,
          design_content.displayable_boxes.map { |box|
            sortable_element(design_id_for_blocks(box),
              :url => {:action => 'design_editor_set_blocks_order', :box_id => box.id  },
              :complete => visual_effect(:highlight, design_id_for_blocks(box)),
              :failure => "$('#{design_id_for_box(box)}').innerHTML= request.responseText",
              :constraint => false,
              :dropOnEmpty => true,
              :containment =>  design_content.displayable_boxes.collect {|b| design_id_for_blocks(b)}
            )
          }.join("\n"),
          :id => 'design_editor_make_sortable'
        )
      end

    end # END OF module Helper

  end # END OF module Editor

end # END OF module Design
