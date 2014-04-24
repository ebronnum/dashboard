require "csv"

class Maze < Level
  def self.create_from_level_builder(params)
    contents = CSV.new(params[:maze_source].read)
    game = Game.custom_maze
    size = params[:size].to_i

    begin
      maze = Level.parse_maze(contents, params[:type], size)
    rescue ArgumentError
      render status: :not_acceptable, text: "There is a non integer value in the grid." and return
    end

    skin = params[:type] == 'maze' ? 'birds' : 'farmer'
    @level = Level.create(params.merge(game: game, level_num: 'custom', skin: skin))
    @level.properties.update(maze)
    @level.save!
  end

  def complete_toolbox
    '<xml id="toolbox" style="display: none;">
      <block type="maze_moveForward"></block>
      <block type="maze_turn">
        <title name="DIR">turnLeft</title>
      </block>
      <block type="maze_turn">
        <title name="DIR">turnRight</title>
      </block>
      <block type="maze_forever"></block>
      <block type="maze_if">
        <title name="DIR">isPathLeft</title>
      </block>
      <block type="maze_if"></block>
      <block type="maze_ifElse"></block>
      <block type="controls_repeat">
        <title name="TIMES">5</title>
      </block>
      <block type="maze_forever"></block>
      <block type="maze_if">
        <title name="DIR">isPathLeft</title>
      </block>
      <block type="maze_if">
        <title name="DIR">isPathRight</title>
      </block>
      <block type="maze_ifElse"></block>
    </xml>'
  end
end
