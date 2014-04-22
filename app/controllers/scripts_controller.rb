class ScriptsController < ApplicationController
  before_filter :authenticate_user!, except: :show
  check_authorization

  def index
    authorize! :manage, Script
    # Show all the scripts that a user has created.
    @scripts = Script.all
  end

  def show
    authorize! :read, Script
    @script = Script.find(params[:id])
  end
end
