module Design

  module Helper

    # proxies calls to controller's design method to get the design information
    # holder object
    def design_interface
      @controller.send(:design_interface)
    end

    # proxies calls to controller's design method to get the design information
    # holder object
    def design_content
      @controller.send(:design_content)
    end

    ########################################################
    # Boxes and Blocks related
    ########################################################

    # Displays +content+ inside the design used by the controller. Normally
    # you'll want use this method in your layout view, like this:
    #
    #   <%= design_display(yield) %>
    #
    # +content+ will be put inside all the blocks which return +true+ in the
    # Block.main? method.
    #
    # The number of boxes generated will be no larger than the maximum number
    # supported by the template, which is indicated in its YAML description
    # file.
    #
    # If not blocks are present (e.g. the design holder has no blocks yet),
    # +content+ is returned right away.
    #
    # If running in design_editor mode
    def design_display(content = "")

      # dispatch to Design::Editor::Helper if running in editor mode
      if (self.respond_to?(:design_display_editor) && params[:action] == 'design_editor')
        return content_tag('div', design_display_editor(content), :id => 'boxes', :class => 'design_boxes')
      end

      # dont draw boxes in other design_editor actions
      if (params[:action] =~ /^design_editor/)
        return content_tag('div', content, :id => 'boxes', :class => 'design_boxes')
      end

      # no blocks. nothing to be done
      if design_content.boxes.empty? || design_content.blocks.empty?
        return content_tag('div', content, :id => 'boxes', :class => 'design_boxes')
      end

      # Generate all boxes of the current profile and considering the defined
      # on template.

      template = Design::Template.find(design_interface.template)

      content_tag(:div, design_boxes(design_content.displayable_boxes.reverse, content), :id => 'boxes', :class => 'design_boxes')
    end

    def design_boxes(boxes, content = '')
      content_tag(:div,
        boxes.map do |box|
          design_box(box, content)
        end.join("\n") + 
        design_boxes_footer
      )
    end

    def design_boxes_footer
      content_tag(:div, '', :id => 'design_boxes_footer')
    end

    def design_box(box, content = '')
      content_tag(:div, 
        [
          design_blocks(box, content), 
          design_box_footer(box)
        ].join("\n"),
        :id => design_id_for_box(box), :class => 'design_box'
      )
    end

    def design_box_footer(box)
      content_tag(:div, '', :class => "design_box_footer", :id => design_id_for_box_footer(box) )
    end

    def design_id_for_box_footer(box)
      "design_box_footer_#{box.id}"
    end
 

    def design_id_for_box(box)
      "design_box_#{box.number}"
    end

    # Displays all the blocks in a box.
    #   <ul id="sort#{number of the box}">
    #     <li class="block_item_box_#{number of the box}" id="block_#{id of block}">
    #     </li>
    #   </ul>
    #
    def design_blocks(box, content = "")
      content_tag(:div,
        box.blocks_sort_by_position.map do |block|
          design_block(block, content)
        end.join("\n")+
        design_blocks_footer,
        :class => 'design_blocks', :id => design_id_for_blocks(box)
      )
    end

    def design_id_for_blocks(box)
      "design_blocks_#{box.id}"
    end

    def design_blocks_footer
      content_tag(:div, '', :class => 'design_blocks_footer')
    end

    def design_block(block, content = '')
      content_tag(:div,
        design_block_core(block, content),
        :class => "design_block", :id =>  design_id_for_block(block)
      )
    end

    def design_block_core(block, content = '')
      content_tag(:div,
        [
          design_block_header_full(block),
          design_block_content(block, content),
          design_block_footer(block)
        ].join("\n"),
        :class => "design_block_type #{block.class.name.gsub('Design::', '').underscore}"
      )
    end
    
    def design_id_for_block(block)
      "design_block_#{block.id}"
    end

    def design_id_for_block_control_options(block)
      "design_block_control_options_#{block.id}"
    end

    def design_block_footer(block)
      content_tag(:div, '', :class => "design_block_footer", :id => design_id_for_block_footer(block) )
    end

    def design_id_for_block_footer(block)
      "design_block_footer_#{block.id}"
    end

    def design_block_header_full(block)
      return '' unless block.display_header?
      [
        design_block_controls(block),
        design_block_header(block) 
      ].join("\n")
    end

    def design_block_header(block)
      content_tag(:h3,
        [
          block.display_title? ? (block.title.blank? ? _('(no title)') : block.title) : ''
        ].join("\n"),
        :class => 'design_block_header', :id => design_id_for_block_header(block)
      )
    end

    def design_id_for_block_header(block)
      "design_block_header_#{block.id}"
    end


    def design_block_controls(block)
      content_tag(:ul,
        [
          content_tag(:li,
            link_to_function(
              content_tag(:span, t(:design_label_hide) ),
              {},
              {:onclick => visual_effect(:toggle_slide, design_id_for_block_content(block), :duration => 0.5), :class => 'design_button_block button_block_hide'}
            ),
            :class => 'design_block_control_item'
          )
        ].join("\n"),
        :class => 'design_block_control_list'
      )
    end 

    # Displays the content of a block. See plugin README for details about the
    # possibilities.
    def design_block_content(block, action_content)
      content_tag(:div,
        design_block_content_core(block, action_content),
        :class => "design_block_content", :id => design_id_for_block_content(block)
      )
    end

    def design_block_content_core(block, action_content)
      text =
        if block.main? || request.xml_http_request?
          action_content
        else
          render_component(:controller => block.controller_name.underscore, :action => 'index', :params => params.merge(:block_id => block.id))
        end

      [
        content_tag(:div, text),
        design_block_content_footer(block)
      ].join("\n")
    end

    def design_block_content_footer(block)
      content_tag(:div, '', :class => "design_block_content_footer", :id => design_id_for_block_content_footer(block) )
    end

    def design_id_for_block_content_footer(block)
      "design_block_content_footer_#{block.id}"
    end
 
    def design_id_for_block_content(block)
      "design_block_content_#{block.id}"
    end
 
    ####################################
    # TEMPLATES
    ####################################

    # Generates <script> tags for all existing javascript files of the current
    # design template.
    #
    # The javascript files must be named as *.js and must be under
    # #{RAILS_ROOT}/public/#{DesignConfiguration.design_root}/templates/#{templatename}/javascripts.
    def design_template_javascript_include_tags
      pattern = File.join(DesignConfiguration.public_filesystem_root, DesignConfiguration.design_root, 'templates', design_interface.template, 'javascripts', '*.js')
      javascript_files = Dir.glob(pattern)

      return '' if javascript_files.empty?

      javascript_files.map do |filename|
        javascript_include_tag('/' + File.join(DesignConfiguration.design_root, 'templates', design_interface.template, 'javascripts', File.basename(filename)))
      end.join("\n")
    end

    # Generates links to all the CSS files provided by the template being used.
    #
    # The CSS files must be named as *.css and live in the directory
    # #{RAILS_ROOT}/public/#{DesignConfiguration.design_root}/templates/#{templatename}/stylesheets/
    def design_template_stylesheet_link_tags
      dirname = File.join(
        DesignConfiguration.public_filesystem_root,
        DesignConfiguration.design_root,
        'templates',
        design_interface.template,
        'stylesheets')

      pattern = File.join(dirname, '*.css' )
      stylesheet_files = Dir.glob(pattern)

      stylesheet_filter = [
       'style.css',
        params[:controller] +'.css',
        params[:controller] +'_'+ params[:action] +'.css',
        params[:action] +'.css',
      ]

      stylesheet_files = stylesheet_filter.map do |f| 
        File.join(dirname, f) if stylesheet_files.include? File.join(dirname,f)
      end

      stylesheet_files.compact!

      return '' if stylesheet_files.empty?

      stylesheet_files.map do |filename|
        stylesheet_link_tag(
          '/'+ File.join(
            DesignConfiguration.design_root,
            'templates',
            design_interface.template,
            'stylesheets',
            File.basename(filename)
          )
        )
      end.join("\n")
    end

    # generates an image tag for the thumbnail in +customization+.
    # +customization+ can be a Design::Template, Design::Theme or
    # Design::IconTheme.
    def design_thumbnail_for(customization)
      image_tag("/#{DesignConfiguration.design_root}/#{customization.class.folder_name}/#{customization.name}/thumbnail.jpg", :alt => customization.title, :title => customization.title)
    end

    #################################################
    #THEMES 
    #################################################

    # generates links for all existing theme CSS files in the current design.
    #
    # The CSS files must be named as *.css and live in the directory
    # #{RAILS_ROOT}/public/#{DesignConfiguration.design_root}/themes/{theme_name}/
    def design_theme_stylesheet_link_tags
      pattern = File.join(
        DesignConfiguration.public_filesystem_root,
        DesignConfiguration.design_root,
        'themes',
          design_interface.theme,
        'stylesheets',
        '*.css' )
      stylesheet_files = Dir.glob(pattern)

      return '' if stylesheet_files.empty?

      stylesheet_files.map do |filename|
        stylesheet_link_tag(
          '/'+ File.join(
            DesignConfiguration.design_root,
            'themes',
            design_interface.theme,
            'stylesheets',
            File.basename(filename)
          )
        )
      end.join("\n") 

    end

    ###############################################
    # ICON THEME STUFF
    ###############################################

    # generates links for all existing icon CSS files in the current design.
    #
    # The CSS files must be named as style.css and live in the directory
    # #{RAILS_ROOT}/public/#{DesignConfiguration.design_root}/icons/{icon_theme_name}/
    def design_icon_theme_stylesheet_link_tags
      pattern = File.join(DesignConfiguration.public_filesystem_root, DesignConfiguration.design_root, 'icons', design_interface.icon_theme, '*.css')
      stylesheet_files = Dir.glob(pattern)

      return '' if stylesheet_files.empty?

      stylesheet_files.map do |filename|
        stylesheet_link_tag('/' + File.join(DesignConfiguration.design_root, 'icons', design_interface.icon_theme, File.basename(filename)))
      end.join("\n")
    end

    # Displays a link or a link_to_remote with the class html option
    # equal to +class_icon+ param added to html_options passed as argument.
    #   EX:
    #     design_display_button(
    #                 'icon_class', 
    #                 'Some Name', 
    #                 {:action => 'Some'}, 
    #                 {:id => 'some_id', :class => '.class_test'}
    #       )
    #    The result is
    #    link_to(
    #       content_tag(:span, 'Some Name'),
    #       {:action => 'Some'},
    #       {:id => 'some_id', :class => '.class_test .icon_class'}
    #
    #    )
    #
    #
    # The application must use this class to print a image to the button.
    #
    # +options+ and +html_options+ are passed to +link_to+ or +link_to_remote+,
    # depending wheter remote is false or true.
    def design_display_button(class_icon, name, options = {}, html_options={}, remote = false)

      html_options = design_calculate_html_options(class_icon, html_options)

      if remote
        link_to_remote(content_tag(:span, name), options, html_options)
      else
        link_to( content_tag(:span, name), options, html_options)
      end
    end

    def design_display_function_button(class_icon, name, js_code, html_options = {})

      html_options = design_calculate_html_options(class_icon, html_options)

      link_to_function( content_tag(:span, name), js_code, html_options)
    end


    # displays a div with the icon +name+ as class.
    #
    # +html_options+ is passed as is to +image_tag+
    def design_display_icon(class_icon, title,  html_options = {})
      html_options = design_calculate_html_options(class_icon, html_options) 
      content_tag(:div, content_tag(:span, title) , html_options)
    end

    # displays a submit_tag with a class html options parameter equal to
    # equal to +class_icon+ param added to html_options passed as argument.
    # 
    # +html_options+ are passed to +submit_tag+
    # If the class 'with_text' is passed in html_options variable the name 
    # passed as parameter will be displayed.
    def design_display_button_submit(class_icon, name, html_options={})

      html_options = design_calculate_html_options(class_icon, html_options) 
      name  = (html_options[:class]['with_text'])? name : ''
      html_options[:title] ||= name
      submit_tag(name, html_options )
    end

    def design_display_button_submit_to_remote(class_icon, name, value, options={}, html_options = {})
      html_options[:html] = design_calculate_html_options(class_icon, html_options) 
      submit_to_remote(name, value, options.merge(html_options) )
    end


    def design_calculate_html_options(class_icon, html_options)
      class_options = "button #{class_icon}"
      
      if html_options[:class].nil?
        html_options[:class] =  "#{class_options}"
      else
        html_options[:class] = "#{class_options} #{html_options[:class]}"
      end

      html_options #Make the return value more clear
    end

    ###############################################
    # GENERAL UTILITIES
    ###############################################

    # generates all header tags needed to use the design. The same as calling +design_template_javascript_include_tags+, +design_template_stylesheet_link_tags+ and 'design_theme_stylesheet_link_tags
    def design_all_header_tags
      [
        # javascript_include_tag(:defaults),
        design_template_stylesheet_link_tags,
        design_theme_stylesheet_link_tags,
        design_icon_theme_stylesheet_link_tags,
      ].join("\n")
    end

  end # END OF module Helper

end #END OF module Design
