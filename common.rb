require_relative 'output_parser'

class Commmon
  PLAYER_MAIN_DETAILS = {:name => 'Player', :species => 'Human',
    :background => 'Fighter'}
  PLAYER_SECOND_DETAILS = {:weapon => 'short sword'}
  DIRECTION_LIST = [:north, :northwest, :west, :southwest, :south, :southeast, :east,
    :northeast]
  ITEM_TYPES = {')' => :weapon,'(' => :missle,'[' => :armor,'%' => :food,'?' => :scroll,
    '!' => :potion,'/' => :ward,'=' => :ring,'"' => :amulet,'\\' => :stave,'|' => :rod,
    '+' => :spellbook,':' => :spellbook,'}' => :misc,'$' => :gold}
  IMMOVABLE_OBJECTS = {:ground => ['.'], :walls => ['#'], :stairs => ['<','>'] }
  KNOWN_OBJECTS = {:creatures => ('a'..'z').to_a, :stairs => ['<','>'],:hero => ['@'],
    :items => ITEM_TYPES.keys}.merge(IMMOVABLE_OBJECTS)

  def self.all_immovable_objects
    IMMOVABLE_OBJECTS
  end

  def self.all_known_objects
    KNOWN_OBJECTS
  end

  def self.create_crawl_arguments(player_details)
    cmd_arguements = ''
    PLAYER_MAIN_DETAILS.each do |key,value|
      new_value = (player_details[key] || value)
      cmd_arguements += " -#{key} #{new_value}"
    end

    cmd_arguements += ' -extra-opt-first'
    PLAYER_SECOND_DETAILS.each do |key,value|
      new_value = (player_details[key] || value)
      cmd_arguements += " #{key}='#{new_value}'"
    end
    cmd_arguements
  end

  def self.display_screen(output)
    OutputParser.new.display_screen(output)
  end
end
