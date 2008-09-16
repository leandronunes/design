class Design::Template < Design::Customization

  def self.folder_name
    'templates'
  end

  def number_of_boxes
    @data['number_of_boxes'] || 3
  end

end
