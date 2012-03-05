require 'bashparser'

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
  DIRECTION_OFFSET = {'north' => [0,-1], 'south' => [0,1], 'east' => [1,0], 'west' => [-1,0]}

  def self.get_direction_offset(direction)
    offset = [0,0]
    DIRECTION_OFFSET.each do |direction, offset_modifier|
      if direction.to_s.include?(direction)
        offset = add_coordinates(offset,offset_modifier)
      end
    end
    offset
  end

  def self.add_coordinates(locA, locB)
    [ locA[0] + locB[0],  locA[1] + locB[1] ]
  end

  def self.get_new_coordinates(start_location, direction, distance = 1)
    offset = get_direction_offset(direction)
    new_location = start_location.dup
    distance.times do
      new_location = add_coordinates(new_location, offset)
    end
    new_location
  end

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
    BashParser.new.display_screen(output)
  end
end
