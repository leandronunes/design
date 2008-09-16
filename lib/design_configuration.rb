class DesignConfiguration

  def DesignConfiguration.design_blocks_controller_path
    pattern = File.join(DesignConfiguration.design_blocks_root, '*', 'controllers')
    Dir.glob(pattern)
  end 

  def DesignConfiguration.design_blocks_helper_path
    pattern = File.join(DesignConfiguration.design_blocks_root, '*', 'helpers')
    Dir.glob(pattern)
  end 

  def DesignConfiguration.design_blocks_model_path
    pattern = File.join(DesignConfiguration.design_blocks_root, '*', 'models')
    Dir.glob(pattern)
  end 

  def DesignConfiguration.design_blocks_root
    DesignConfiguration.instance_variable_get('@design_blocks_root').blank? ? File.join(RAILS_ROOT, 'app', 'design_blocks') : DesignConfiguration.instance_variable_get('@design_blocks_root')
  end 

  def DesignConfiguration.design_blocks_root=(value)
    DesignConfiguration.instance_variable_set('@design_blocks_root', value)
  end

  # returns the path to the designs directory, relative to the +RAILS_ROOT+
  # directory of your application.
  #
  # Defaults to 'designs'
  def DesignConfiguration.design_root
    DesignConfiguration.instance_variable_get('@design_root').blank? ? DesignConfiguration.design_root_default : DesignConfiguration.instance_variable_get('@design_root')
  end

  #Default directory template for design 
  def DesignConfiguration.design_root_default
    'designs'
  end

  # sets the path to the designs directory.
  #
  # Passing nil resets +design_root+ to its default value.
  def DesignConfiguration.design_root=(dir)
    DesignConfiguration.instance_variable_set('@design_root', dir)
  end

  # Sets the path to the app filesystem directory
  # Defaults to RAILS_ROOT
  def DesignConfiguration.public_filesystem_root # :nodoc:
    DesignConfiguration.instance_variable_get('@public_filesystem_root') || File.join(RAILS_ROOT, 'public')
  end

  # Sets the path to the app filesystem directory
  def DesignConfiguration.public_filesystem_root=(value) # :nodoc:
    DesignConfiguration.instance_variable_set('@public_filesystem_root', value)
  end

  def DesignConfiguration.available_templates
    Dir.glob(File.join(DesignConfiguration.public_filesystem_root, DesignConfiguration.design_root, 'templates', '*')).select {|item| File.directory?(item) }.map {|item| File.basename(item) }
  end

  def DesignConfiguration.available_themes
    Dir.glob(File.join(DesignConfiguration.public_filesystem_root, DesignConfiguration.design_root, 'themes', '*')).select {|item| File.directory?(item) }.map {|item| File.basename(item) }
  end

  def DesignConfiguration.available_icon_themes
    Dir.glob(File.join(DesignConfiguration.public_filesystem_root, DesignConfiguration.design_root, 'icons', '*')).select {|item| File.directory?(item) }.map {|item| File.basename(item) }
  end



end
