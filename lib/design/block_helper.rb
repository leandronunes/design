module Design
  module Helper
    module Block
     
      #FIXME make this test
      def design_link_to_remote(name, options = {}, html_options = {})
        options[:failure] = "$('#{design_id_for_block(@design_block)}').innerHTML= request.responseText"
        options[:method] ||= :get
        link_to_remote(name, options, html_options)
      end

    end # END OF module Block

  end # END OF module Helper

end #END OF module Design
