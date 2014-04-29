# A sequence of Levels
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
        add_script(options, data)
      end

      # Load custom scripts from generate_scripts ruby DSL (csv as intermediate format)
      Dir.glob('config/scripts/**/*.script').flatten.each do |script|
        params = {name: File.basename(script, ".script"), trophies: false, hidden: true}
        data = ApplicationHelper.parse_csv(`config/generate_scripts #{script}`, "\t", SCRIPT_MAP)
        add_script(params, data, true)
      end
      touch
    end
  end

  def self.add_script(options, data, custom=false)
    v = 'wrapup_video'; options[v] = Video.find_by_key(options[v]) if options.has_key? v
    script = Script.where(options).first_or_create
    chapter = 0; game_chapter = Hash.new(0)
    script.script_levels = data.map do |row|

      # Concepts are comma-separated, indexed by name
      row['concept_ids'] = (concepts = row.delete('concepts')) && concepts.split(',').map(&:strip).map do |concept_name|
        (Concept.find_by_name(concept_name) || raise("missing concept '#{concept_name}'")).id
      end

      # Reference one Level per element
      level = custom ?
        Level.find_by(name: row['name']) :
        Level.where(game: Game.find_by(name: row.delete('game')), level_num: row['level_num']).first_or_create

      raise "There does not exist a level with the name '#{row['name']}'. From the row: #{row}" if level.nil?
      raise "Level #{level.to_json}, does not have a game." if level.game.nil?
      stage = row.delete('stage')
      level.update(row)

      script_level = ScriptLevel.where(
          script: script,
          level: level,
          chapter: (chapter += 1),
          game_chapter: (game_chapter[level.game] += 1)
      ).first_or_create

      # Set/create Stage containing custom ScriptLevel
      if stage
        script_level.update(stage: Stage.where(name: stage, script: script).first_or_create)
        script_level.move_to_bottom
      end
      script_level
    end
  end
end
