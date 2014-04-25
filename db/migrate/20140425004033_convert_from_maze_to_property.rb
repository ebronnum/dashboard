class ConvertFromMazeToProperty < ActiveRecord::Migration
  def change
    Level.all.each do |level|
      if !level.maze.nil?
        level.property.update(maze: JSON.parse(level.maze))
        level.save!
      end
    end
  end
end
