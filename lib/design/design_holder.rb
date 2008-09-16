module Design

  class DesignHolder
    attr_reader :content, :interface
    def initialize(interface, content)
      @content = content
      @interface = interface
    end
  end
end

