class DesignBlockGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions class_path, class_name

      # Block, model, controller and view directories.
      design_block_root =  File.join(DesignConfiguration.design_blocks_root, file_name)

      m.directory design_block_root
      m.directory File.join( design_block_root, 'controllers')
      m.directory File.join( design_block_root, 'models')
      m.directory File.join( design_block_root, 'views')
      m.directory File.join( design_block_root, 'helpers')

      # Generating the model and controller files
      m.template 'model.rb',        File.join( design_block_root, 'models', "#{file_name}.rb")
      m.template 'controller.rb',   File.join( design_block_root, 'controllers', "#{file_name}_controller.rb")
      m.template 'helper.rb',   File.join( design_block_root, 'helpers', "#{file_name}_helper.rb")

      # Generating views files. 
      # FIXME Generate some default actions?
#      actions << 'index'
#      actions << 'edit'
      actions.uniq!

      actions.each do |action|
        path = File.join(design_block_root, 'views', "#{action}.rhtml")
        template = File.exists?(File.join(File.dirname(__FILE__), 'templates', "#{action}.rhtml")) ? "#{action}.rhtml" : 'view.rhtml'
        m.template template, path,
          :assigns => { :action => action, :path => path }
      end


    end
  end

end

