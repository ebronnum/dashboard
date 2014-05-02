#!/usr/bin/env ruby

require 'yaml'

class ParseMulti

  $hash
  $name

  def name(text)
    $name = text
  end

  def title(text)
    $hash[:title] = text
  end

  def description(text)
    $hash[:description] = text
  end

  def style(text)
    $hash[:style] = text
  end

  def question(text)
    $hash[:questions] << { text: text }
  end

  def right(text)
    $hash[:answers] << { text: text, correct: true }
  end

  def wrong(text)
    $hash[:answers] << { text: text, correct: false }
  end

  def answer(text)
    $hash[:answers] << { text: text }
  end

  def parse(filename)
    $hash = { :questions => [], :answers => [] }
    instance_eval(File.read(filename))
    { name: $name, properties: $hash }
  end

end

# for testing
# puts parse_multi("scripts/multis/m_1.multi")
