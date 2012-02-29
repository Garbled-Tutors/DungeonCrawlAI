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

  private
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

#Examining surroundings ('x')
#When roaming the dungeon, the surroundings mode is activated by 'x'. It lets you have a look at items or monsters in line of sight. You may also examine stashed items outside current view using the option target_oos = true (if using this, check the option target_los_first).
#Esc, Space, x
    #Return to playing mode.
#?
    #Special help screen.
#* or '
    #Cycle objects forward.
#/ or ;
    #Cycle objects backward.
#+ or =
    #Cycle monsters forward.
#-
    #Cycle monsters backward.
#direction
    #Move cursor.
#. or Enter
    #Travel to cursor (also Del).
#v
    #Describe feature or monster under cursor. Some branch entries have special information.
#>
    #Cycle downstairs.
#<
    #Cycle upstairs.
#_
    #Cycle through altars.
#Tab
    #Cycle shops and portals.


