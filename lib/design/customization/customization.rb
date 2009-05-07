module Design
  class Customization

    # must return the name of the folder inside +designs+ in which your type of
    # customization resides (e.g. +'templates'+ for templates.)
    #
    # In this class, this method throws an exeception. Subclasses must override
    # this method.
    def self.folder_name
      raise "#{self.class} should override Design::Customization.folder_name"
    end

    def initialize(name, data)
      @data = data
      @data['name'] = name
    end

    def self.all
      pattern = File.join(DesignConfiguration.public_filesystem_root, DesignConfiguration.design_root, self.folder_name, '*', '*.yml')
      Dir.glob(pattern).map do |yaml_file|
        data = YAML.load_file(yaml_file)
        self.new(File.basename(File.dirname(yaml_file)), data)
      end

    end

    def self.find(name)
      directory = File.join(DesignConfiguration.public_filesystem_root, DesignConfiguration.design_root, self.folder_name, name)
      yaml_files = Dir.glob(File.join(directory, '*.yml'))

      if yaml_files.size != 1
        raise "#{name} is not a valid #{self.name}. There must be one (and only one) YAML (*.yml) file describing it in #{directory})"
      end

      data = YAML.load_file(yaml_files.first)

      self.new(name, data)
    end

    def name
      @data['name']
    end

    def title
      @data['title'] || name
    end

    def description
      @data['description']
    end

    def number_of_boxes
      @data['number_of_boxes'] || 3
    end

  end
end
