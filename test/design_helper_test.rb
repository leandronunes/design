require File.join(File.dirname(__FILE__), 'test_helper')

class DesignHelperTestController < ActionController::Base
  
  box1 = Design::Box.new(:number => 1)

  proc_block = Design::Block.new(:position => 1)
  def proc_block.content
    lambda do
      link_to 'test link', :controller => 'controller_linked_from_block'
    end
  end
  box1.blocks << proc_block

  array_block = Design::Block.new(:position => 2)
  def array_block.content
    [ 'item1', 'item2', 'item3' ]
  end
  box1.blocks << array_block

  box2 = Design::Box.new(:number => 2)
  box2.blocks << Design::MainBlock.new(:position => 1)

  box3 = Design::Box.new(:number => 3)
  fixed_text_block = Design::Block.new(:position => 1)
  def fixed_text_block.content
    "this is a fixed content block hacked for testing"
  end
  box3.blocks << fixed_text_block

  design :fixed => {
    :template => 'default',
    :theme => 'default',
    :icon_theme => 'default',
    :filesystem => File.dirname(__FILE__),
    :boxes => [ box1, box2, box3 ],
  }

  def index
    render :inline => '<%= design_display("my content") %>'
  end

  def javascript
    render :inline => '<%=  design_template_javascript_include_tags %>'
  end

  def template_stylesheets
    render :inline => '<%= design_template_stylesheet_link_tags  %>'
  end

  def theme_stylesheets
    render :inline => '<%= design_theme_stylesheet_link_tags %>'
  end

  def buttons
    # one with extension and other without
    render :inline => '
      <%= design_display_button("something", "Something") %>
      <%= design_display_button("another", "Another") %>
    '
  end

  def icons
    render :inline => '
      <%= design_display_icon("something") %>
      <%= design_display_icon("another") %>
    '
  end

  def all_header_tags
    render :inline => '<%= design_all_header_tags %>'
  end

  def path_for_template_thumbnail
    render :inline => '<%= design_thumbnail_for(Design::Template.find("default"))  %>'
  end

  def path_for_theme_thumbnail
    render :inline => '<%= design_thumbnail_for(Design::Theme.find("default"))  %>'
  end

  def path_for_icon_theme_thumbnail
    render :inline => '<%= design_thumbnail_for(Design::IconTheme.find("default"))  %>'
  end

end

#FIXME class used by test test_should_call_method_when_passing_symbol_as_holder
#The test is commented so this class definition is commented to.
#See if we are going to use it.
#class DesignHelperTestWithHolderAsSymbolController < ActionController::Base
#
#  design :holder => :my_method
#  def my_method
#  end
#end

class DesignHelperTestController; def rescue_action(e) raise e end; end

class DesignHelperTest < Test::Unit::TestCase

  def setup
    @controller = DesignHelperTestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    Design.public_filesystem_root = File.join(File.dirname(__FILE__))
  end

  def teardown
    Design.public_filesystem_root = nil
  end

  def test_should_generate_all_boxes
    get :index
    assert_response :success
    assert_tag :tag => 'div', :attributes => { :id => 'box_1' }
    assert_tag :tag => 'div', :attributes => { :id => 'box_2' }
    assert_tag :tag => 'div', :attributes => { :id => 'box_3' }
  end

  def test_should_render_array_as_list
    get :index
    assert_response :success
    assert_tag :tag => 'ul', :descendant => {
      :tag => 'li', :content => 'item1'
    }
    assert_tag :tag => 'ul', :descendant => {
      :tag => 'li', :content => 'item2'
    }
    assert_tag :tag => 'ul', :descendant => {
      :tag => 'li', :content => 'item3'
    }
  end

  def test_should_process_a_proc_block_returned_as_content
    get :index
    assert_response :success
    assert_tag :tag => 'a', :attributes => { :href => /controller_linked_from_block/ }
  end

  def test_should_put_string_as_is
    get :index
    assert_response :success
    assert_tag :tag => 'div',
      :content => "this is a fixed content block hacked for testing"
  end

  def test_should_provide_javascript_link_if_available
    get :javascript
    assert_response :success
    assert_tag :tag => 'script', :attributes => {
      :type => 'text/javascript',
      :src => '/designs/templates/default/javascripts/one.js'
    }
    assert_tag :tag => 'script', :attributes => {
      :type => 'text/javascript',
      :src => '/designs/templates/default/javascripts/two.js'
    }
  end

  def test_should_provide_stylesheet_links_if_available
    get :template_stylesheets
    assert_response :success
    assert_tag :tag => 'link', :attributes => {
      :type => 'text/css',
      :href => '/designs/templates/default/stylesheets/one.css'
    }
    assert_tag :tag => 'link', :attributes => {
      :type => 'text/css',
      :href => '/designs/templates/default/stylesheets/two.css'
    }
  end

  def test_should_provide_theme_stylesheet_links_if_available
    get :theme_stylesheets
    assert_response :success
    assert_tag :tag => 'link', :attributes => {
      :type => 'text/css',
      :href => '/designs/themes/default/one.css'
    }
  end

  def test_should_support_displaying_buttons
    get :buttons
    assert_response :success
    assert_tag :tag => 'a', :attributes => {
      :class => /none_something something/
    }, :descendant => {
      :tag => 'span',
      :content => /Something/
    }
    assert_tag :tag => 'a', :attributes => {
      :class => /none_another another/
    }, :descendant => {
      :tag => 'span',
      :content => /Another/
    }
  end

  def test_should_support_displaying_icons
    get :icons
    assert_tag :tag => 'div', :attributes => {
      :class => /none_something something/
    }
    assert_tag :tag => 'div', :attributes => {
      :class => /none_another another/
    }
  end

  def test_should_provide_full_header_tags
    get :all_header_tags
    assert_response :success

    # template JS
    assert_tag :tag => 'script', :attributes => {
      :type => 'text/javascript',
      :src => '/designs/templates/default/javascripts/one.js'
    }
    assert_tag :tag => 'script', :attributes => {
      :type => 'text/javascript',
      :src => '/designs/templates/default/javascripts/two.js'
    }

    # template CSS
    assert_tag :tag => 'link', :attributes => {
      :type => 'text/css',
      :href => '/designs/templates/default/stylesheets/one.css'
    }
    assert_tag :tag => 'link', :attributes => {
      :type => 'text/css',
      :href => '/designs/templates/default/stylesheets/two.css'
    }

    # theme CSS
    assert_tag :tag => 'link', :attributes => {
      :type => 'text/css',
      :href => '/designs/themes/default/one.css'
    }

  end

#FIXME See if we are going to have a holder like a method
#  def test_should_call_method_when_passing_symbol_as_holder
#    controller = DesignHelperTestWithHolderAsSymbolController.new
#    controller.expects(:my_method)
#    controller.send(:design)
#  end

  def test_should_generate_correct_path_for_template_thumbnail
    get :path_for_template_thumbnail
    assert_tag :tag => 'img', :attributes => {
      :src => /templates\/default\/thumbnail.png/
    }
  end
  def test_should_generate_correct_path_for_theme_thumbnail
    get :path_for_theme_thumbnail
    assert_tag :tag => 'img', :attributes => {
      :src => /themes\/default\/thumbnail.png/
    }
  end
  def test_should_generate_correct_path_for_icon_theme_thumbnail
    get :path_for_icon_theme_thumbnail
    assert_tag :tag => 'img', :attributes => {
      :src => /icons\/default\/thumbnail.png/
    }
  end

end
