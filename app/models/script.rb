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

  def self.setup
    Script.transaction do
      ApplicationHelper.reset_db self

      # Load default scripts from yml (csv embedded)
      Dir.glob("config/scripts/default/*.yml").map do |yml|
        ApplicationHelper.load_yaml(yml, SCRIPT_MAP)
      end.sort_by { |options, _| options['id'] }.map do |options, data|
        add_scripts(options, data)
      end

      # Load custom scripts from generate_scripts ruby DSL (csv as intermediate format)
      Dir.glob('config/scripts/**/*.script').flatten.each do |script|
        params = {name: File.basename(script, ".script"), trophies: false, hidden: true}
        data = ApplicationHelper.parse_csv(`config/generate_scripts #{script}`, "\t", SCRIPT_MAP)
        add_scripts(params, data, true)
      end
      touch
    end
  end

  def self.add_scripts(options, data, custom=false)
    v = 'wrapup_video'; options[v] = Video.find_by_key(options[v]) if options.has_key? v
    script = Script.where(options).first_or_create
    chapter = 0; game_chapter = Hash.new(0)
    script_levels = data.map do |row|
      # Reference one Level per element
      if custom
        # Custom scripts require levels to be in the database
        level = get_level_by_name(row['name']).first
        raise "There does not exist a level with the name '#{row['name']}'. From the row: #{row}" if level.nil?
        game = level.game
        raise "Level #{level.to_json}, does not have a game." if game.nil?
      else
        # Hardcoded scripts create new level entries (the level is already in Blockly)
        game = Game.find_by_name row['game']
        level = Level.where(game: game, level_num: row['level_num']).first_or_create
        level.name = row['name']
        level.level_url ||= row['level_url']
        level.skin = row['skin']
      end
      # Concepts are comma-separated, indexed by name
      level.concepts ||= (concepts=row['concepts']) && concepts.split(',').map do |concept_name|
          concept = Concept.find_by_name concept_name
          raise "missing concept '#{concept_name}'" if concept.nil?
      end
      level.save!
      # Update script_level with script and chapter.
      # Note: we should not have two script_levels associated with the same script and chapter ids.
      script_level = ScriptLevel.where(
          script: script,
          chapter: (chapter += 1),
          game_chapter: (game_chapter[game] += 1),
          level: level
      ).first_or_create
      # Set/create Stage in custom ScriptLevels
      if row['stage']
        stage = Stage.where(name: row['stage'], script: script).first_or_create
        script_level.update(stage: stage)
        script_level.move_to_bottom
      end
    end
    # Delete all ScriptLevels no longer found in the current script
    (ScriptLevel.where(script: script).to_a - script_levels).each { |sl| ScriptLevel.delete(sl) }
  end

end
