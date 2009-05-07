module Design
  module Editor
    module BlockHelper

#FIXME See if it's a good idea
#We have to guarantee that the options for url has the params:
#   {:controller => @design_block.class.name.underscore, :block_id => @design_bloc}
#
#Actualy we are redefining all rails methods that has parameters
#
#
#    DESIGN_METHODS = %w[
#      link_to_remote
#    ]
#
#    DESIGN_METHODS.each do |design_method|
#      define_method("design_#{design_method}") do |args |
#        args[:url].merge!({:controller => @design_block.class.name.underscore, :block_id => @design_bloc})
#        self.send(design_method, args)
#      end
#    end

#FIXME Make this test

#        def design_form_remote_tag(options = {},&block) 
## <% 
##form_remote_for(@design_block, :failure =>"$('#{design_id_for_block(@design_block)}').innerHTML= request.responseText", :html => {:method => :put}) do  
##%>
#
#          options[:failure] = "$('#{design_id_for_block(@design_block)}').innerHTML= request.responseText" # "alert(request.responseText)"
##          options[:url].merge!({:controller => @design_block.class.name.underscore, :block_id => @design_block})
#          options[:url].merge!({:controller => @design_block.class.name.underscore, :block_id => @design_block})
#          form_remote_tag(options, &block)
#        end

#<% form_remote_for(@design_block, :failure =>"$('#{design_id_for_block(@design_block)}').innerHTML= request.responseText", :html => {:method => :put}) do  %>

     
      #FIXME make this test     
      def design_form_remote_for(options = {},&block) 
        options[:failure] = "$('#{design_id_for_block(@design_block)}').innerHTML= request.responseText" # "alert(request.responseText)"
        design_block = self.instance_variable_get('@design_block')
        form_remote_for(design_block, options, &block)
      end
 
    end # END OF module BlockHelper
  end # END OF module Editor
end #END OF module Design
