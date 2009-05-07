require 'routing'
require 'acts_as_design'
require 'design/controller_methods'
require 'design/design_configuration'

# Customization Stuff
require 'design/customization/customization'
require 'design/customization/icon_theme'
require 'design/customization/theme'
require 'design/customization/template'

# Block Stuff
require 'acts_as_design_block'

#require 'design/box'
#require 'design/block'
#require 'design/main_block'



#require 'design/design_holder'
#require 'design/editor'
#require 'design/fixed_design_holder'


# extra directories for design controllers organization 
design_blocks_controller_paths = DesignConfiguration.design_blocks_controller_path
design_blocks_controller_paths.each do |item|
  $LOAD_PATH << item
  ActiveSupport::Dependencies.load_paths << item
  ActiveSupport::Dependencies.load_once_paths.delete(item)
end

# extra directories for design helpers organization 
design_blocks_helper_paths = DesignConfiguration.design_blocks_helper_path
design_blocks_helper_paths.each do |item|
  $LOAD_PATH << item
  ActiveSupport::Dependencies.load_paths << item
  ActiveSupport::Dependencies.load_once_paths.delete(item)
end

# extra directories for design model organization 
design_blocks_model_paths = DesignConfiguration.design_blocks_model_path
design_blocks_model_paths.each do |item|
  $LOAD_PATH << item
  ActiveSupport::Dependencies.load_paths << item
  ActiveSupport::Dependencies.load_once_paths.delete(item)
end
