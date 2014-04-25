# An ordered sequence of Levels
class Script < ActiveRecord::Base
  has_many :levels, through: :script_levels
  has_many :script_levels
  has_many :stages
  belongs_to :wrapup_video, foreign_key: 'wrapup_video_id', class_name: 'Video'
  belongs_to :user

  # Hardcoded scriptID constants used throughout the code
  TWENTY_HOUR_ID = 1
  HOC_ID = 2
  EDIT_CODE_ID = 3
  TWENTY_FOURTEEN_LEVELS_ID = 4
  BUILDER_ID = 5
  FLAPPY_ID = 6
  JIGSAW_ID = 7

  def self.touch
    @@last_updated = Time.now
  end

  touch

  def self.cached(id)
    Rails.cache.fetch("script/#{id}/#{@@last_updated}") do
      find(id)
    end
  end

  def script_levels_from_game(game_id)
    self.script_levels.select { |sl| sl.level.game_id == game_id }
  end

  def multiple_games?
    # simplified check to see if we are in a script that has only one game (stage)
    levels.first.game_id != levels.last.game_id
  end

  def twenty_hour?
    self.id == TWENTY_HOUR_ID
  end

  def hoc?
    self.id == HOC_ID
  end

  def find_script_level(level_id)
    self.script_levels.detect { |sl| sl.level_id == level_id }
  end

  def self.twenty_hour_script
    Script.cached(TWENTY_HOUR_ID)
  end

  def get_script_level_by_id(script_level_id)
    self.script_levels.select { |sl| sl.id == script_level_id }.first
  end

  def get_script_level_by_chapter(chapter)
    self.script_levels.select { |sl| sl.chapter == chapter }.first
  end

  SCRIPT_CSV_MAPPING = %w(Game Name Level:level_num Skin Concepts Url:level_url Stage)
  SCRIPT_MAP = Hash[SCRIPT_CSV_MAPPING.map { |x| x.include?(':') ? x.split(':') : [x, x.downcase] }]
  SCRIPTS_GLOB = Dir.glob('config/scripts/**/*.script').flatten

  def self.setup
    Script.transaction do
      ApplicationHelper.reset_db self
      # array of script hashes
      Dir.glob("config/scripts/default/*.yml").map do |yml|
        ApplicationHelper.load_yaml(yml, SCRIPT_MAP)
      end.sort_by { |options, _| options['id'] }.map do |options, data|
        add_scripts(options, data)
      end

      SCRIPTS_GLOB.each do |file|
        script_name = file.gsub(/.*\/(\w+).script$/, '\1')
        csv = `config/generate_scripts #{file}`
        params = {name: script_name, trophies: false, hidden: true}
        data = ApplicationHelper.parse_csv(csv, "\t", SCRIPT_MAP)
        add_scripts(params, data, true)
      end
      touch
    end
  end

  def self.add_scripts(options, data, custom=false)
    options.each_key do |k|
      options[k] = Video.find_by_key(options[k]) if k == 'wrapup_video'
    end
    game_map = Game.all.index_by(&:name)
    concept_map = Concept.all.index_by(&:name)

    # Create Script entry
    script = Script.where(options).first_or_create
    old_script_levels = ScriptLevel.where(script: script).to_a # tracks which levels are no longer included in script.
    game_index = Hash.new(0)

    data.each_with_index do |row, index|
      # Reference one Level per element
      if custom
        level = get_level_by_name(row['name']).first
        if level.nil?
          raise "There does not exist a level with the name '#{row['name']}'. From the row: #{row}"
        end
        game = level.game
        raise "Level #{level.to_json}, does not have a game." if game.nil?
      else
        game = game_map[row['game'].squish]
        level = Level.where(game: game, level_num: row['level_num']).first_or_create
        level.name = row['name']
        level.level_url ||= row['level_url']
        level.skin = row['skin']
      end

      # Concepts are comma-separated CSV column, indexed by name
      if level.concepts.empty? && row['concepts']
        row['concepts'].split(',').each do |concept_name|
          concept = concept_map[concept_name.squish]
          if concept
            level.concepts << concept
          else
            raise "missing concept '#{concept_name}'"
          end
        end
      end
      level.save!

      # Update script_level with script and chapter. Note: we should not have two script_levels associated with the
      # same script and chapter ids.
      script_level = ScriptLevel.where(
          script: script,
          chapter: (index + 1),
          game_chapter: (game_index[game.id] += 1),
          level: level
      ).first_or_create
      old_script_levels.delete(script_level) # we found this ScriptLevel in a script, so don't delete it

      # Set stage in custom ScriptLevels
      if row['stage']
        stage = Stage.where(name: row['stage'], script: script).first_or_create
        script_level.update(stage: stage)
        script_level.move_to_bottom
      end
    end
    # Delete all ScriptLevels no longer found in the current script
    old_script_levels.each { |sl| ScriptLevel.delete(sl) }
  end

end
