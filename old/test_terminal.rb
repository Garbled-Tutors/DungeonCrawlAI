INACTIVE = nil
ESCAPE_BYTE = 27

def handle_read(pipe)
  Thread.current['output'] = ''
  Thread.current['clear'] = false
  until pipe.eof?
    current_char = pipe.getc
    Thread.current['output'] = '' if Thread.current['clear']
    Thread.current['output'] += current_char
    Thread.current['clear'] = false
  end
end

def parse_input(input)
  input.each_byte do |byte|
    @all_input += byte.chr
    write_byte_to_screen(byte) if @escape_code == INACTIVE
    read_for_escape_codes(byte)
  end
end

def read_for_escape_codes(byte)
  char = byte.chr
  @escape_code += char if @escape_code != INACTIVE
  @escape_code = '' if byte == ESCAPE_BYTE

  byte_is_letter = char != char.swapcase
  if @escape_code != INACTIVE and byte_is_letter
    handle_escape_code
    @escape_code = INACTIVE
  end
end

def write_byte_to_screen(byte)
  if byte == 13
    @y += 2
    @x = 0
  elsif byte == 8
    @x -= 1
    @x = 0 if @x < 0
  elsif byte == 10
    @y += 1
  elsif byte >= 32
    @screen[@y] = [] unless @screen[@y]
    @screen[@y][@x] = byte.chr
    @x += 1
  end
end

def handle_escape_code
  if @escape_code == '[H'
    @y = 0
    @x = 0
  elsif @escape_code == '[2J'
    reset_screen
  elsif @escape_code[-1] == 'H'
    position = @escape_code[1..-2].split(';')
    @y = position[0].to_i - 1
    @x = position[1].to_i - 1
  elsif @escape_code[-1] == 'd'
    distance = @escape_code[1..-2].to_i
    @y = distance - 1
  elsif @escape_code == '[C'
    @x +=1
  elsif @escape_code[-1] == 'C'
    distance = @escape_code[1..-2].to_i
    @x += distance
  elsif @escape_code[-1] == 'G'
    distance = @escape_code[1..-2].to_i
    @x = distance - 1
  end
end

def get_screen_contents
  @screen.dup.map do |line|
    (line || []).map { |char| char || ' ' }.join
  end
end

def display_screen
  File.open('screen', 'w') do |f|
    get_screen_contents.each { |line| f.puts line }
  end
end

def take_screen_shot
  File.open('screenshot', 'w') do |f|
    @all_input.dup.each_byte do |byte|
      f.putc(byte)
    end
    f.putc(27)
    f.puts('[20;0H')
  end
end

def reset_screen
  @x = 0
  @y = 0
  @screen = []
  @all_input = 27.chr + '[2J'
  @escape_code = INACTIVE
end

reset_screen
IO.popen('crawl', "w+") do |pipe|
  pipe.flush
  read_thread = Thread.fork {handle_read(pipe)}

  while true
    sleep(1)
    parse_input(read_thread['output'])
    take_screen_shot
    p "asking for input"
    r = gets
    p r
  end
  `reset`
end

