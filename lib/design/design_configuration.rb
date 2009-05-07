# FIXME Make this test
class DesignConfiguration

  # Set the +design_root+ and +public_filesystem_root+ customized by user.
  def self.set_default_config(design_holder)
    design_interface = design_holder.interface

    DesignConfiguration.design_root = design_interface.class.design_root if design_interface.class.respond_to?('design_root')
    DesignConfiguration.design_root = design_interface.design_root if design_interface.respond_to?('design_root')

    DesignConfiguration.public_filesystem_root = design_interface.class.public_filesystem_root if design_interface.class.respond_to?('public_filesystem_root')
    DesignConfiguration.public_filesystem_root = design_interface.public_filesystem_root if design_interface.respond_to?('public_filesystem_root')
  end

  # Return all controllers defined on blocks
  def self.design_blocks_controller_path
    pattern = File.join(self.design_blocks_root, '*', 'controllers')
    Dir.glob(pattern)
  end 

  # Return all helpers defined on blocks
  def self.design_blocks_helper_path
    pattern = File.join(self.design_blocks_root, '*', 'helpers')
    Dir.glob(pattern)
  end 

  # Return all models defined on blocks
  def self.design_blocks_model_path
    pattern = File.join(self.design_blocks_root, '*', 'models')
    Dir.glob(pattern)
  end   

  # Return the path for config block directory
  def self.design_blocks_config_path
    pattern = File.join(self.design_blocks_root, '*', 'config')
    Dir.glob(pattern)
  end

  # Set the place where the blocks will be create.
  def self.design_blocks_root
    self.instance_variable_get('@design_blocks_root').blank? ? File.join(RAILS_ROOT, 'app', 'design_blocks') : self.instance_variable_get('@design_blocks_root')
  end 

  def self.design_blocks_root=(value)
    self.instance_variable_set('@design_blocks_root', value)
  end

  # returns the path to the designs directory, relative to the +RAILS_ROOT+
  # directory of your application.
  #
  # Defaults to 'designs'
  def self.design_root
    self.instance_variable_get('@design_root').blank? ? self.design_root_default : self.instance_variable_get('@design_root')
  end

  #Default directory template for design 
  def self.design_root_default
    'designs'
  end

  # sets the path to the designs directory.
  #
  # Passing nil resets +design_root+ to its default value.
  def self.design_root=(dir)
    self.instance_variable_set('@design_root', dir)
  end

  # Sets the path to the app filesystem directory
  # Defaults to RAILS_ROOT
  def self.public_filesystem_root # :nodoc:
    self.instance_variable_get('@public_filesystem_root') || File.join(RAILS_ROOT, 'public')
  end

  # Sets the path to the app filesystem directory
  def self.public_filesystem_root=(value) # :nodoc:
    self.instance_variable_set('@public_filesystem_root', value)
  end

  def self.available_templates
    Dir.glob(File.join(self.public_filesystem_root, self.design_root, 'templates', '*')).select {|item| File.directory?(item) }.map {|item| File.basename(item) }
  end

  def self.available_themes
    Dir.glob(File.join(self.public_filesystem_root, self.design_root, 'themes', '*')).select {|item| File.directory?(item) }.map {|item| File.basename(item) }
  end

  def self.available_icon_themes
    Dir.glob(File.join(self.public_filesystem_root, self.design_root, 'icons', '*')).select {|item| File.directory?(item) }.map {|item| File.basename(item) }
  end

end
