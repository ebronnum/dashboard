require 'test_helper'

class LevelTest < ActiveSupport::TestCase
  setup do
    @custom_data = {"game_id"=>23, "user_id" => 1, "name"=>"__bob4", "level_num"=>"custom", "skin"=>"artist", "solution_level_source_id"=>4, "user_id"=>1, "instructions"=>"sdfdfs"}
    @data = {"game_id"=>23, "name"=>"__bob4", "level_num"=>"custom", "skin"=>"artist", "solution_level_source_id"=>4, "user_id"=>1, "instructions"=>"sdfdfs"}
    @custom_level = Level.create(@custom_data)
    @level = Level.create(@data)
  end

  test "cannot create two custom levels with same name" do
    assert_no_difference('Level.count') do
      level2 = Level.create(@custom_data)
      assert_not level2.valid?
      assert level2.errors.include?(:name)
    end
  end

  test "can create two custom levels with different names" do
    assert_difference('Level.count', 1) do
      @custom_data["name"] = "__swoop"
      level2 = Level.create(@custom_data)
      assert level2.valid?
    end
  end

  test "get custom levels" do
    assert Level.custom_levels.include?(@custom_level)
    assert_not Level.custom_levels.include?(@level)
  end
end
