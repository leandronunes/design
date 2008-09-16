require 'design/controller_methods'
require 'design/fixed_design_holder'
require 'design/customization'
require 'design/template'
require 'design/theme'
require 'design/icon_theme'

require 'design/helper'
require 'design/editor'

module Design

  def design_plugin_data
    @design_plugin_data ||= Hash.new
  end

  # gets the Design object for this controller
  def design
    data = design_plugin_data

    return data[:design] if data.has_key?(:design)

    config = self.class.design_plugin_config

    if config[:fixed].kind_of? Hash
      options = config[:fixed] || {}
      design_holder = Design::FixedDesignHolder.new(options)
      content_holder = interface_holder = design_holder
    else
      content_holder_name = config[:content_holder] || config[:holder] 
      if content_holder_name.kind_of? Symbol
        content_holder = self.send(content_holder_name)
      else
        content_holder = self.instance_variable_get("@#{content_holder_name}")
      end

      interface_holder_name = config[:interface_holder] || config[:holder] 
      if interface_holder_name.kind_of? Symbol
        interface_holder = self.send(interface_holder_name)
      else
        interface_holder = self.instance_variable_get("@#{interface_holder_name}")
      end
    end

    raise "You must have at least the interface defined" if interface_holder.blank?

    data[:design] = DesignHolder.new(interface_holder, content_holder)

    if data[:design].interface.respond_to?('design_root')
      DesignConfiguration.design_root = data[:design].interface.design_root 
    else
      DesignConfiguration.design_root = data[:design].interface.class.design_root 
    end
    
    if data[:design].interface.respond_to?('public_filesystem_root')
      DesignConfiguration.public_filesystem_root = data[:design].interface.public_filesystem_root
    else
      DesignConfiguration.public_filesystem_root = data[:design].interface.class.public_filesystem_root
    end
    
    data[:design] # redundant, but makes more clear the return value
  end

  def design_interface
    design.interface
  end

  def design_content
    design.content
  end

  protected :design, :design_interface

end
