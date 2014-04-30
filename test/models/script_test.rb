require 'test_helper'

class ScriptTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test 'create script from script text' do
    Game.create!(name: 'test game')
    script = Script.add_script(
      {name: 'test script'},
      [{game: 'test game', name: 'test level', level_num: 'test_level'}]
    )
    puts "script: #{script}"
  end
end
