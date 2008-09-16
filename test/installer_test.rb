require File.join(File.dirname(__FILE__), 'test_helper')
require 'design/installer'

class InstallerTest < Test::Unit::TestCase

  ROOT = File.join(File.dirname(__FILE__), 'tmp-install')

  def setup
    FileUtils.mkdir(ROOT)
    Design::Installer.install(ROOT, false)
  end

  def teardown
    FileUtils.rm_rf(ROOT)
  end

  def test_should_create_designs_directory
    assert File.directory?(File.join(ROOT, 'public', 'designs'))
  end

  def test_should_create_templates_directory
    assert File.directory?(File.join(ROOT, 'public', 'designs', 'templates'))
  end

  def test_should_create_themes_directory
    assert File.directory?(File.join(ROOT, 'public', 'designs', 'themes'))
  end

  def test_should_create_icon_themes_directory
    assert File.directory?(File.join(ROOT, 'public', 'designs', 'icons'))
  end

  def test_should_copy_default_template
    assert File.directory?(File.join(ROOT, 'public', 'designs', 'templates', 'default'))
    # FIXME: look for stylesheet
  end

  def test_should_copy_default_theme
    assert File.directory?(File.join(ROOT, 'public', 'designs', 'themes', 'default'))
    # FIXME: look for stylesheet
  end

  def test_should_copy_default_icon_theme
    assert File.directory?(File.join(ROOT, 'public', 'designs', 'icons', 'default'))
    # FIXME: look for images
  end

end
