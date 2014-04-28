# A Concept contains a set of Levels
# A Video can be associated with a Concept
# Trophies are awarded based on percentage completion of Concepts
class Concept < ActiveRecord::Base
  has_and_belongs_to_many :levels
  belongs_to :video
  # Can't call static from filter. Leaving in place for fixing later
  after_save :expire_cache

  def self.cached
    @@all_cache ||= Concept.all
  end

  def expire_cache
    @@all_cache = nil
  end

  def self.setup
    Concept.transaction do
      ApplicationHelper.reset_db self
      %w(sequence if if_else loop_times loop_until loop_while loop_for function parameters).each do |concept|
        Concept.create!(name: concept, video: Video.find_by_key(concept))
      end
    end
  end
end
