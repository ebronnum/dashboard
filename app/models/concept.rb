# A Concept is a subset of Levels
# A Video can be associated with a Concept
# Trophies are awarded based on percentage completion of Concepts
class Concept < ActiveRecord::Base
  has_and_belongs_to_many :levels
  belongs_to :video
  # Can't call static from filter. Leaving in place for fixing later
  #after_save :expire_cache

  def self.cached
    @@all_cache ||= Concept.all
  end

  def self.expire_cache
    @@all_cache = nil
  end

  def setup
    Concept.transaction do
      Concept.delete_all # use delete instead of destroy so callbacks are not called
      Concept.connection.execute("ALTER TABLE concepts auto_increment = 1")
      concept_id = 0
      %w(sequence if if_else loop_times loop_until loop_while loop_for function parameters events).each do |concept|
        video =
        Concept.create!(id: concept_id += 1, name: concept)
      end
      Concept.create!(id: concept_id += 1, name: 'sequence')
      Concept.create!(id: concept_id += 1, name: 'if', video: Video.find_by_key('if'))
      Concept.create!(id: concept_id += 1, name: 'if_else', video: Video.find_by_key('if_else'))
      Concept.create!(id: concept_id += 1, name: 'loop_times', video: Video.find_by_key('loop_times'))
      Concept.create!(id: concept_id += 1, name: 'loop_until', video: Video.find_by_key('loop_until'))
      Concept.create!(id: concept_id += 1, name: 'loop_while', video: Video.find_by_key('loop_while'))
      Concept.create!(id: concept_id += 1, name: 'loop_for', video: Video.find_by_key('loop_for'))
      Concept.create!(id: concept_id += 1, name: 'function', video: Video.find_by_key('function'))
      Concept.create!(id: concept_id += 1, name: 'parameters', video: Video.find_by_key('parameters'))
    end
  end
end
