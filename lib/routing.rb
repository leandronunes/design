#FIXME make this tests
module Design
  module RailsExtensions
    module Routing

      # Loads the set of routes from design blocks.
      #
      # Plugin routes are loaded from <tt><design_block_root>/config/routes.rb</tt>.
      def design_plugin(path = {})
        map = self # to make 'map' available within the plugin route file

        config_path = DesignConfiguration.design_blocks_config_path
        config_path.each do |config|
          routes_path = File.join(config,'routes.rb')
          eval(IO.read(routes_path), binding, routes_path) if File.file?(routes_path)
        end
      end
      
    end
  end
end

  
module ::ActionController #:nodoc:
  module Routing #:nodoc:
    class RouteSet #:nodoc:
      class Mapper #:nodoc:
        include Design::RailsExtensions::Routing
      end
    end
  end
end


