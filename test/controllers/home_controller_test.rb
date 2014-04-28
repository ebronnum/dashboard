# -*- coding: utf-8 -*-
require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "language is determined from cookies" do
    @request.cookies[:language_] = "es-ES"

    get :index

    assert_select 'a', 'Iniciar Sesión'
  end

  test "language is set with cookies" do
    sign_in User.new # devise uses an empty user instead of nil? Hm

    request.host = "learn.code.org"

    get :set_locale, :return_to => "http://blahblah", :locale => "es-ES"

    assert_equal "es-ES", cookies[:language_]

    assert_equal "language_=es-ES; domain=.code.org; path=/", @response.headers["Set-Cookie"]
  end

  test "should get index with edmodo header" do
    @request.headers["Accept"] = "image/*"
    @request.headers["User-Agent"] = "Edmodo/14 CFNetwork/672.0.2 Darwin/14.0.0"
    get :index
    assert_response :success
  end

  test "should get index with weebly header" do
    @request.headers["Accept"] = "image/*"
    @request.headers["User-Agent"] = "weebly-agent"
    get :index
    assert_response :success
  end

  test "logged in user with gallery activities shows gallery" do
    user = create(:user)
    activity1 = create(:activity, user: user)
    GalleryActivity.create!(activity: activity1, user: user)
    activity2 = create(:activity, user: user)
    GalleryActivity.create!(activity: activity2, user: user)
    sign_in user

    get :index

    assert_select 'h4', "Gallery:" # title of the gallery section
    assert_select 'div.gallery_activity img', 2 # 2 gallery items

  end

  test "logged in user without gallery activities does not show gallery" do
    user = create(:user)
    create(:activity, user: user)
    sign_in user

    get :index

    assert_response :success
    assert_select 'h4', text: "Gallery", count: 0
  end

  test "do not show gallery when not logged in" do
    get :index
    assert_select 'h4', text: "Gallery", count: 0
  end

  test "do not show admin links when not admin" do
    sign_in create(:user)

    get :index
    assert_select 'a[href=/admin/stats]', 0
  end

  test "do show admin links when admin" do
    sign_in create(:admin)

    get :index
    assert_select 'a[href=/admin/stats]'
  end

# this exception is actually annoying to handle because it never gets
# to ActionController (so we can't use the rescue in
# ApplicationController)
#  test "bad http methods are rejected" do
#    process :index, 'APOST' # use an APOST instead of get/post/etc
#
#    assert_response 400
#  end


end
