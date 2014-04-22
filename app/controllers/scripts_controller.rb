class ScriptsController < ApplicationController
  before_filter :authenticate_user!, except: :show
  check_authorization

  def index
    authorize! :manage, Script
    # Show all the scripts that a user has created.
    @scripts = Script.all
  end

  def new
    authorize! :manage, Script
    @script = Script.new
  end

  def create
    authorize! :manage, Script
    params[:script].require(:name)
    script = Script.create!(name: params[:script][:name], user: current_user)
    flash.notice = t("builder.created")
    redirect_to scripts_path
  end

  def edit
    authorize! :manage, Script
    @script = Script.find(params[:id])
    @play_script_path = script_level_path(@script, ScriptLevel.where(chapter: 1, script: @script).first)
    # Get all levels that were created by seed (null user) or this user.
    @levels = Level.where("user_id is NULL or user_id = ?", current_user)
  end

  def sort
    render nothing: true
  end

  def destroy
    authorize! :manage, Script
    Script.find(params[:id]).destroy
    flash.notice = t("builder.destroyed")
    redirect_to scripts_path
  end

  def show
    authorize! :read, Script
    @script = Script.find(params[:id])
  end
end
