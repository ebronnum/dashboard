require 'test_helper'

class LocaleHelperTest < ActionController::TestCase
  tests ApplicationController
  include LocaleHelper

  test "should accept iso language code as valid locale" do
    I18n.with_locale('es') do
        locale
    end
  end
end
