require 'test_helper'

class ScriptTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test 'create script' do
    @game = FactoryGirl.create(:game)
    Script.setup([],[File.join(self.class.fixture_path, "test.script")])
    script_levels = Script.add_script(
      {name: 'test script 2'},
      [{game: @game.name, name: 'test level', level_num: 'test_level'}]
    )
    puts "script: #{script_levels}, game: #{@game.to_json}"
  end
end
