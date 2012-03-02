class ScreenParser
  def self.parse_screen(output)
    screen = OutputParser.new.parse_input(output)
    {:stats => parse_stats(screen), :visible => parse_visible(screen) }
  end

  def self.parse_full_map(output)
    screen = OutputParser.new.parse_input(output)
    floor_map = []
    floor_map = screen.map { |line| line.split(//) }.dup

    objects = {:hero => [], :stairs => [], :walls => [], :ground => [], :map => floor_map}

    floor_map.each_index do |y|
      (floor_map[y] || []).each_index do |x|
        contents = floor_map[y][x]
        Commmon.all_immovable_objects.each do |name,abv_array|
          objects[name] << [x,y] if abv_array.include?(contents)
        end
        objects[:hero] = [x,y] if contents == '@'
      end
    end
    objects
  end

  def self.get_object_notes(output)
    screen = OutputParser.new.parse_input(output)
    if screen[-2][0..5].include?('Here:')
      screen[-2]
    else
      nil
    end
  end

  def self.parse_creatures(output)
    creatures = []
    parse_object_array(output).each do |creature|
      main_details = creature[0].split(' (')[0].split(', ')
      creature_name = main_details[0]
      weapon_notes = main_details[1..-1]
      notes = (creature[0] + ' ').split('(')[1..-1].map { |i| i.split(')')[0..-2] }
      notes.flatten!
      notes = notes[0].split(', ') if notes[0]
      notes += weapon_notes
      creatures << {:name => creature_name, :coordinates => [creature[1], creature[2]], :notes => notes}
    end
    creatures[0..-2]
  end
  private

  def self.parse_object_array(output)
    monster_data = output.split("\n")[-1]
    output_parser = OutputParser.new
    object_data = output_parser.seperate_by_cursor_jumps(monster_data)
    object_data[1][2][0] = object_data[1][2][0][8..-1] #hack
    results = []
    1.step(object_data.length - 1, 3) do |index|
      results << [object_data[index][2][0], object_data[index + 1][1], object_data[index + 1][0] ]
    end
    results[0..-1] #last result is always the hero
  end
  def self.parse_stats(screen)
    panel = screen[0..9].map { |line| line[37..-1] }

    name_and_background = panel[0].split(' the ')
    name = name_and_background[0]
    background = name_and_background[-1]
    species = panel[1].split(' ')[-1]

    notes = (4..7).map { |i| panel[i].split(' ') }
    notes.flatten!
    0.step(16,2) { |i| notes[i] = nil }
    notes.delete(nil)
    ac,str,ev,int,sh,dex,level,exp,place = notes

    branch, floor = place.split(':')

    health = panel[2].split(' ')[1].split('/')
    magic = panel[3].split(' ')[1].split('/')
    weapon = panel[8][7..-1]
    quivered = panel[9][7..-1]

    {:name => name, :species => species, :background => background,
      :health => health, :magic => magic, :ac => ac, :str => str, :ev => ev,
      :int => int, :sh => sh, :dex => dex,:branch => branch, :floor => floor,
      :exp => exp, :floor => floor, :weapon => weapon, :quivered => quivered}
  end

  def self.parse_visible(screen)
    floor_map = []
    floor_map = screen[0..16].map { |line| line[0..36].split(//) }

    #floor_map.each { |line| p (line || []).join }
    objects = {:hero => [], :creatures => [], :items => [], :stairs => [],
      :walls => [], :ground => [], :map => floor_map.dup}

    floor_map.each_index do |y|
      (floor_map[y] || []).each_index do |x|
        contents = floor_map[y][x]
        Commmon.all_known_objects.each do |name,abv_array|
          objects[name] << [x,y] if abv_array.include?(contents)
        end
      end
    end
    objects[:hero] = objects[:hero][0]
    objects
  end
end
