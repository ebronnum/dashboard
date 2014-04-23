require "csv"

namespace :seed do
  task videos: :environment do
    Video.transaction do
      Video.delete_all # use delete instead of destroy so callbacks are not called
      Video.connection.execute("ALTER TABLE videos auto_increment = 1")

      video_id = 0
      CSV.read('config/videos.csv', { col_sep: "\t", headers: true }).each do |row|
        Video.create!(key: row['Key'], youtube_code: row['YoutubeCode'], download: row['Download'], :id => video_id += 1)
      end
    end

    if !Rails.env.test?
      Rake::Task["youtube:thumbnails"].invoke
    end
  end

  task concepts: :environment do
    Concept.transaction do
      Concept.delete_all # use delete instead of destroy so callbacks are not called
      Concept.connection.execute("ALTER TABLE concepts auto_increment = 1")
      concept_id = 0
      Concept.create!(id: concept_id += 1, name: 'sequence')
      Concept.create!(id: concept_id += 1, name: 'if', video: Video.find_by_key('if'))
      Concept.create!(id: concept_id += 1, name: 'if_else', video: Video.find_by_key('if_else'))
      Concept.create!(id: concept_id += 1, name: 'loop_times', video: Video.find_by_key('loop_times'))
      Concept.create!(id: concept_id += 1, name: 'loop_until', video: Video.find_by_key('loop_until'))
      Concept.create!(id: concept_id += 1, name: 'loop_while', video: Video.find_by_key('loop_while'))
      Concept.create!(id: concept_id += 1, name: 'loop_for', video: Video.find_by_key('loop_for'))
      Concept.create!(id: concept_id += 1, name: 'function', video: Video.find_by_key('function'))
      Concept.create!(id: concept_id += 1, name: 'parameters', video: Video.find_by_key('parameters'))
      Concept.create!(id: concept_id += 1, name: 'events')
    end
  end
  task games: :environment do
    Game.transaction do
      Game.delete_all # use delete instead of destroy so callbacks are not called
      Game.connection.execute("ALTER TABLE games auto_increment = 1")
      game_id = 0
      Game.create!(id: game_id += 1, name: 'Maze', app: 'maze', intro_video: Video.find_by_key('maze_intro'))
      Game.create!(id: game_id += 1, name: 'Artist', app: 'turtle', intro_video: Video.find_by_key('artist_intro'))
      Game.create!(id: game_id += 1, name: 'Artist2', app: 'turtle')
      Game.create!(id: game_id += 1, name: 'Farmer', app: 'maze', intro_video: Video.find_by_key('farmer_intro'))
      Game.create!(id: game_id += 1, name: 'Artist3', app: 'turtle')
      Game.create!(id: game_id += 1, name: 'Farmer2', app: 'maze')
      Game.create!(id: game_id += 1, name: 'Artist4', app: 'turtle')
      Game.create!(id: game_id += 1, name: 'Farmer3', app: 'maze')
      Game.create!(id: game_id += 1, name: 'Artist5', app: 'turtle')
      Game.create!(id: game_id += 1, name: 'MazeEC', app: 'maze', intro_video: Video.find_by_key('maze_intro'))
      Game.create!(id: game_id += 1, name: 'Unplug1', app: 'unplug')
      Game.create!(id: game_id += 1, name: 'Unplug2', app: 'unplug')
      Game.create!(id: game_id += 1, name: 'Unplug3', app: 'unplug')
      Game.create!(id: game_id += 1, name: 'Unplug4', app: 'unplug')
      Game.create!(id: game_id += 1, name: 'Unplug5', app: 'unplug')
      Game.create!(id: game_id += 1, name: 'Unplug6', app: 'unplug')
      Game.create!(id: game_id += 1, name: 'Unplug7', app: 'unplug')
      Game.create!(id: game_id += 1, name: 'Unplug8', app: 'unplug')
      Game.create!(id: game_id += 1, name: 'Unplug9', app: 'unplug')
      Game.create!(id: game_id += 1, name: 'Unplug10', app: 'unplug')
      Game.create!(id: game_id += 1, name: 'Unplug11', app: 'unplug')
      Game.create!(id: game_id += 1, name: 'Bounce', app: 'bounce')
      Game.create!(id: game_id += 1, name: "Custom", app: "turtle")
      Game.create!(id: game_id += 1, name: 'Flappy', app: 'flappy', intro_video: Video.find_by_key('flappy_intro'))
      Game.create!(id: game_id += 1, name: "CustomMaze", app: "maze")
      Game.create!(id: game_id += 1, name: "Studio", app: "studio")
      Game.create!(id: game_id += 1, name: "Jigsaw", app: 'jigsaw')
    end
  end

  COL_GAME = 'Game'
  COL_STAGE = 'Stage'
  COL_NAME = 'Name'
  COL_LEVEL = 'Level'
  COL_CONCEPTS = 'Concepts'
  COL_URL = 'Url'
  COL_SKIN = 'Skin'
  COL_INSTRUCTIONS = 'Instructions'
  COL_MAZE = 'Maze'
  COL_X = 'X'
  COL_Y = 'Y'
  COL_START_DIRECTION = 'Start_direction'
  COL_START_BLOCKS = 'Start_blocks'
  COL_TOOLBOX_BLOCKS = 'Toolbox_blocks'
  COL_SOLUTION = 'Solution'

  task custom_levels: :environment do
    Level.transaction do
      JSON.parse(File.read("config/scripts/custom_levels.json")).each do |row|
        levels = get_level_by_name(row['name'])
        level = levels.first_or_create
        game = Game.find(row['game_id'])
        level.update(instructions: row['instructions'], skin: row['skin'], maze: row['maze'], x: row['x'], y: row['y'], start_blocks: row['start_blocks'], toolbox_blocks: row['start_blocks'], start_direction: row['start_direction'], game: game)
        solution = row['properties']['solution_blocks']
        if solution
          level.update(solution_level_source: LevelSource.lookup(level, solution))
        end
      end
    end
  end

  def get_level_by_name(name)
    levels = Level.where(name: name)
    if levels.count > 1
      raise "There exists more than one level with name '#{name}'."
    end
    levels
  end

  task scripts: :environment do
    Rake::Task["seed:custom_levels"].invoke
    Script.transaction do
      game_map = Game.all.index_by(&:name)
      concept_map = Concept.all.index_by(&:name)

      sources = [
                 { file: 'config/script.csv', params: { name: '20-hour', trophies: true, hidden: false }},
                 { file: 'config/hoc_script.csv', params: { name: 'Hour of Code', wrapup_video: Video.find_by_key('hoc_wrapup'), trophies: false, hidden: false }},
                 { file: 'config/ec_script.csv', params: { name: 'Edit Code', wrapup_video: Video.find_by_key('hoc_wrapup'), trophies: false, hidden: true }},
                 { file: 'config/2014_script.csv', params: { name: '2014 Levels', trophies: false, hidden: true }},
                 { file: 'config/builder_script.csv', params: { name: 'Builder Levels', trophies: false, hidden: true }},
                 { file: 'config/flappy_script.csv', params: { name: 'Flappy Levels', trophies: false, hidden: true }},
                 { file: 'config/jigsaw_script.csv', params: { name: 'Jigsaw Levels', trophies: false, hidden: true }}
                ]
      custom_sources = Dir.glob("config/scripts/*.script.csv").map do |script|
        { file: script, custom: true, params: { name: File.basename(script, ".script.csv"), trophies: false, hidden: true }}
      end

      (sources + custom_sources).each do |source|
        script = Script.where(source[:params]).first_or_create
        old_script_levels = ScriptLevel.where(script: script).to_a  # tracks which levels are no longer included in script.
        game_index = Hash.new{|h,k| h[k] = 0}

        CSV.read(source[:file], { col_sep: "\t", headers: true }).each_with_index do |row, index|
          if source[:custom]
            level = get_level_by_name(row[COL_NAME]).first
            if level.nil?
              raise "There does not exist a level with the name '#{row[COL_NAME]}'. From the row: #{row}, From the script: #{source}."
            end
            game = level.game
            raise "Level #{level.to_json}, does not have a game." if game.nil?
          else
            game = game_map[row[COL_GAME].squish]
            level = Level.where(game: game, level_num: row[COL_LEVEL]).first_or_create
            level.name = row[COL_NAME]
            level.level_url ||= row[COL_URL]
            level.skin = row[COL_SKIN]
          end

          if level.concepts.empty?
            if row[COL_CONCEPTS]
              row[COL_CONCEPTS].split(',').each do |concept_name|
                concept = concept_map[concept_name.squish]
                if !concept
                  raise "missing concept '#{concept_name}'"
                else
                  level.concepts << concept
                end
              end
            end
          end
          level.save!
          # Update script_level with script and chapter. Note: we should not have two script_levels associated with the
          # same script and chapter ids.
          script_level = ScriptLevel.where(script: script, chapter: (index + 1)).first
          if (script_level)
            script_level.level = level
            script_level.game_chapter = (game_index[game.id] += 1)
            script_level.save!
            old_script_levels.delete(script_level)
          else
            script_level = ScriptLevel.where(script: script, level: level, chapter: (index + 1), game_chapter: (game_index[game.id] += 1)).first_or_create
          end
          if row[COL_STAGE]
            stage = Stage.where(name: row[COL_STAGE], script: script).first_or_create
            script_level.update(stage: stage)
            script_level.move_to_bottom
          end
        end
        # old_script_levels now contains script_levels that were removed from this csv-based script - clean them up:
        old_script_levels.each { |sl| ScriptLevel.delete(sl) }
      end
    end
  end

  task callouts: :environment do
    Callout.transaction do
      Callout.delete_all # use delete instead of destroy so callbacks are not called
      Callout.connection.execute("ALTER TABLE callouts auto_increment = 1")
      # TODO if the id of the callout is important, specify it in the tsv
      # preferably the id of the callout is not important ;)
      Callout.find_or_create_all_from_tsv!('config/callouts.tsv')
    end
  end

  task trophies: :environment do
    # code in user.rb assumes that broze id: 1, silver id: 2 and gold id: 3.
    Trophy.transaction do
      Trophy.delete_all # use delete instead of destroy so callbacks are not called
      Trophy.connection.execute("ALTER TABLE trophies auto_increment = 1")
      trophy_id = 0
      Trophy.create!(id: trophy_id += 1, name: 'Bronze', image_name: 'bronzetrophy.png')
      Trophy.create!(id: trophy_id += 1, name: 'Silver', image_name: 'silvertrophy.png')
      Trophy.create!(id: trophy_id += 1, name: 'Gold', image_name: 'goldtrophy.png')
    end
  end

  task prize_providers: :environment do
    PrizeProvider.transaction do
      PrizeProvider.delete_all # use delete instead of destroy so callbacks are not called
      PrizeProvider.connection.execute("ALTER TABLE prize_providers auto_increment = 1")

      # placeholder data - id's are assumed to start at 1 so prizes below can be loaded properly
      prize_provider_id = 0
      PrizeProvider.create!(id: prize_provider_id += 1, name: 'Apple iTunes', description_token: 'apple_itunes', url: 'http://www.apple.com/itunes/', image_name: 'itunes_card.jpg')
      PrizeProvider.create!(id: prize_provider_id += 1, name: 'Dropbox', description_token: 'dropbox', url: 'http://www.dropbox.com/', image_name: 'dropbox_card.jpg')
      PrizeProvider.create!(id: prize_provider_id += 1, name: 'Valve Portal', description_token: 'valve', url: 'http://www.valvesoftware.com/games/portal.html', image_name: 'portal2_card.png')
      PrizeProvider.create!(id: prize_provider_id += 1, name: 'EA Origin Bejeweled 3', description_token: 'ea_bejeweled', url: 'https://www.origin.com/en-us/store/buy/181609/mac-pc-download/base-game/standard-edition-ANW.html', image_name: 'bejeweled_card.jpg')
      PrizeProvider.create!(id: prize_provider_id += 1, name: 'EA Origin FIFA Soccer 13', description_token: 'ea_fifa', url: 'https://www.origin.com/en-us/store/buy/fifa-2013/pc-download/base-game/standard-edition-ANW.html', image_name: 'fifa_card.jpg')
      PrizeProvider.create!(id: prize_provider_id += 1, name: 'EA Origin SimCity 4 Deluxe', description_token: 'ea_simcity', url: 'https://www.origin.com/en-us/store/buy/sim-city-4/pc-download/base-game/deluxe-edition-ANW.html', image_name: 'simcity_card.jpg')
      PrizeProvider.create!(id: prize_provider_id += 1, name: 'EA Origin Plants vs. Zombies', description_token: 'ea_pvz', url: 'https://www.origin.com/en-us/store/buy/plants-vs-zombies/mac-pc-download/base-game/standard-edition-ANW.html', image_name: 'pvz_card.jpg')
      PrizeProvider.create!(id: prize_provider_id += 1, name: 'DonorsChoose.org $750', description_token: 'donors_choose', url: 'http://www.donorschoose.org/', image_name: 'donorschoose_card.jpg')
      PrizeProvider.create!(id: prize_provider_id += 1, name: 'DonorsChoose.org $250', description_token: 'donors_choose_bonus', url: 'http://www.donorschoose.org/', image_name: 'donorschoose_card.jpg')
      PrizeProvider.create!(id: prize_provider_id += 1, name: 'Skype', description_token: 'skype', url: 'http://www.skype.com/', image_name: 'skype_card.jpg')
    end
  end

  task ideal_solutions: :environment do
    Level.all.map do |level|
      level_source_id_count_map = Hash.new(0)
      Activity.all.where(['level_id = ?', level.id]).order('id desc').limit(10000).each do |activity|
        level_source_id_count_map[activity.level_source_id] += 1 if activity.test_result >= Activity::FREE_PLAY_RESULT
      end
      best =  level_source_id_count_map.max_by{ |k, v| v};
      level.update_attributes(ideal_level_source_id: best[0]) if best
    end
  end

  task :frequent_level_sources, [:freq_cutoff, :game_name] => :environment do |t, args|
    if args[:game_name]
      puts "Only crowdsourcing hints for " + args[:game_name]
    else
      puts "Crowdsourcing hints for all games."
    end
    # Among all the level_sources, find the ones that are submitted more than freq_cutoff times.
    FrequentUnsuccessfulLevelSource.update_all('active = false')
    freq_cutoff = args[:freq_cutoff].to_i > 0 ? args[:freq_cutoff].to_i : 100
    # 0: level_source_id, 1: level_id, 2: num_of_attempts
    Activity.connection.execute('select level_source_id, level_id, count(*) as num_of_attempts from activities where test_result < 30 group by level_source_id order by num_of_attempts DESC').each do |level_source|
      if !level_source.nil? && !level_source[0].nil? && !level_source[1].nil? && !level_source[2].nil?
        if level_source[2] >= freq_cutoff
          if is_standardized_level_source(level_source[0]) && is_targeted_game(args[:game_name], level_source[1])
            unsuccessful_level_source = FrequentUnsuccessfulLevelSource.where(
                level_source_id: level_source[0],
                level_id: level_source[1]).first_or_create
            unsuccessful_level_source.num_of_attempts = level_source[2]
            if LevelSourceHint.where(level_source_id: unsuccessful_level_source.level_source_id).size < 3
              unsuccessful_level_source.active = true
              unsuccessful_level_source.save!
            end
          end
        else
          break
        end
      end
    end
  end

  def is_standardized_level_source(level_source_id)
    level_source = LevelSource.find(level_source_id)
    if level_source
      !level_source.data.include? "xmlns=\"http://www.w3.org/1999/xhtml\""
    end
  end

  def is_targeted_game(game_name, level_id)
    !game_name || (Level.find(level_id) && Level.find(level_id).game.name == game_name)
  end

  task dummy_prizes: :environment do
    # placeholder data
    Prize.connection.execute('truncate table prizes')
    TeacherPrize.connection.execute('truncate table teacher_prizes')
    TeacherBonusPrize.connection.execute('truncate table teacher_bonus_prizes')
    10.times do |n|
      string = n.to_s
      Prize.create!(prize_provider_id: 1, code: "APPL-EITU-NES0-000" + string)
      Prize.create!(prize_provider_id: 2, code: "DROP-BOX0-000" + string)
      Prize.create!(prize_provider_id: 3, code: "VALV-EPOR-TAL0-000" + string)
      Prize.create!(prize_provider_id: 4, code: "EAOR-IGIN-BEJE-000" + string)
      Prize.create!(prize_provider_id: 5, code: "EAOR-IGIN-FIFA-000" + string)
      Prize.create!(prize_provider_id: 6, code: "EAOR-IGIN-SIMC-000" + string)
      Prize.create!(prize_provider_id: 7, code: "EAOR-IGIN-PVSZ-000" + string)
      TeacherPrize.create!(prize_provider_id: 8, code: "DONO-RSCH-OOSE-750" + string)
      TeacherBonusPrize.create!(prize_provider_id: 9, code: "DONO-RSCH-OOSE-250" + string)
      Prize.create!(prize_provider_id: 10, code: "SKYP-ECRE-DIT0-000" + string)
    end
  end

  task :import_users, [:file] => :environment do |t, args|
    CSV.read(args[:file], { col_sep: "\t", headers: true }).each do |row|
      User.create!(
          provider: User::PROVIDER_MANUAL,
          name: row['Name'],
          username: row['Username'],
          password: row['Password'],
          password_confirmation: row['Password'],
          birthday: row['Birthday'].blank? ? nil : Date.parse(row['Birthday']))
    end
  end

  def import_prize_from_text(file, provider_id, col_sep)
    Rails.logger.info "Importing prize codes from: " + file + " for provider id " + provider_id.to_s
    CSV.read(file, { col_sep: col_sep, headers: false }).each do |row|
      if row[0].present?
        Prize.create!(prize_provider_id: provider_id, code: row[0])
      end
    end
  end

  task :import_itunes, [:file] => :environment do |t, args|
    import_prize_from_text(args[:file], 1, "\t")
  end

  task :import_dropbox, [:file] => :environment do |t, args|
    import_prize_from_text(args[:file], 2, "\t")
  end

  task :import_valve, [:file] => :environment do |t, args|
    import_prize_from_text(args[:file], 3, "\t")
  end

  task :import_ea_bejeweled, [:file] => :environment do |t, args|
    import_prize_from_text(args[:file], 4, "\t")
  end

  task :import_ea_fifa, [:file] => :environment do |t, args|
    import_prize_from_text(args[:file], 5, "\t")
  end

  task :import_ea_simcity, [:file] => :environment do |t, args|
    import_prize_from_text(args[:file], 6, "\t")
  end

  task :import_ea_pvz, [:file] => :environment do |t, args|
    import_prize_from_text(args[:file], 7, "\t")
  end

  task :import_skype, [:file] => :environment do |t, args|
    import_prize_from_text(args[:file], 10, ",")
  end

  task :import_donorschoose_750, [:file] => :environment do |t, args|
    Rails.logger.info "Importing teacher prize codes from: " + args[:file] + " for provider id 8"
    CSV.read(args[:file], { col_sep: ",", headers: true }).each do |row|
      if row['Gift Code'].present?
        TeacherPrize.create!(prize_provider_id: 8, code: row['Gift Code'])
      end
    end
  end

  task :import_donorschoose_250, [:file] => :environment do |t, args|
    Rails.logger.info "Importing teacher bonus prize codes from: " + args[:file] + " for provider id 9"
    CSV.read(args[:file], { col_sep: ",", headers: true }).each do |row|
      if row['Gift Code'].present?
        TeacherBonusPrize.create!(prize_provider_id: 9, code: row['Gift Code'])
      end
    end
  end

  task analyze_data: [:ideal_solutions, :frequent_level_sources]

  task all: [:videos, :concepts, :games, :scripts, :trophies, :prize_providers, :callouts]

end
