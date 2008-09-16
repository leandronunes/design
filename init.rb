require 'design_configuration'
require 'design'
require 'acts_as_design'
require 'acts_as_design_block'

Dependencies.load_once_paths.delete(lib_path)

# extra directories for design controllers organization 
design_blocks_controller_paths = DesignConfiguration.design_blocks_controller_path
design_blocks_controller_paths.each do |item|
  Dependencies.load_paths << item
  $LOAD_PATH << item
  config.controller_paths << item
end

# extra directories for design helpers organization 
design_blocks_helper_paths = DesignConfiguration.design_blocks_helper_path
design_blocks_helper_paths.each do |item|
  Dependencies.load_paths << item
  $LOAD_PATH << item
end



# extra directories for design model organization 
design_blocks_model_paths = DesignConfiguration.design_blocks_model_path
design_blocks_model_paths.each do |item|
  Dependencies.load_paths << item
  $LOAD_PATH << item
end

