class ScriptsController < ApplicationController
  before_filter :authenticate_user!
  check_authorization

  def index
    authorize! :show, Script
    # Show all the scripts that a user has created.
    @scripts = Script.where(user: current_user)
  end

  def new
    authorize! :manage, Script
    @script = Script.new
  end

  def create
    authorize! :manage, Script
    params[:script].require(:name)
    script = Script.create!(name: params[:script][:name], user: current_user)
    flash.notice = "You created a new script."
    redirect_to scripts_path
  end

  def edit
    authorize! :manage, Script
    @script = Script.find(params[:id])
    @current_script_levels = ScriptLevel.where(script_id: params[:id])
    @levels = Level.all
    # Add or remove a level at the specified index in the script.
  end

  def sort
    authorize! :manage, Script

    # Remove all existing script levels and create new ones. Optimize this
    # if it is too slow.
    script = Script.find(params[:id])

    params[:level].each_with_index do |level, index|
      script_level = ScriptLevel.where(level_id: level, script: script).first_or_create # 1 based indexed chapters
      script_level.update(chapter: index + 1, game_chapter: index + 1)
    end
    # old_script_levels now contains script_levels that were removed.
    old_script_levels.each { |sl| ScriptLevel.remove(sl) }

    render nothing: true
  end

  def destroy
    authorize! :manage, Script
    Script.find(params[:id]).destroy
    flash.notice = "You destroyed a script."
    redirect_to scripts_path
  end
end
