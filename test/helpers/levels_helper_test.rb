require 'test_helper'

class LevelsHelperTest < ActionView::TestCase
  include LocaleHelper

  setup do
    @maze_data = {:game_id=>25, :user_id => 1, :name=>"__bob4", :level_num=>"custom", :skin=>"birds", :instructions=>"sdfdfs"}
    @level = Maze.create(@maze_data)
  end

  test "should parse maze level with non string array" do
    @level.properties["maze"] = [[0, 0], [2, 3]]
    level, options = blockly_options
    assert (level["map"].is_a? Array), "Maze is not an array"

    @level.properties["maze"] = @level.properties["maze"].to_s
    level, options = blockly_options
    assert (level["map"].is_a? Array), "Maze is not an array"
  end
end
