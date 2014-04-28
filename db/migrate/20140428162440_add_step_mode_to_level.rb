class AddStepModeToLevel < ActiveRecord::Migration
  def change
    add_column :levels, :step_mode, :integer
  end
end
