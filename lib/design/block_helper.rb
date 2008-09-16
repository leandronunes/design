module Design

  module BlockHelper
 
    def design_link_to_remote(name, options = {}, html_options = {})
      options[:failure] = "$('#{design_id_for_block(@design_block)}').innerHTML= request.responseText"
      options[:url].merge!({:controller => @design_block.class.name.underscore, :block_id => @design_block})
      link_to_remote(name, options, html_options)
    end

  end # END OF module BlockHelper

end #END OF module Design
