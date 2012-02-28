class TerminalEmulator
  INACTIVE = nil
  ESCAPE_BYTE = 27

  def reset_screen
    @x = 0
    @y = 0
    @screen = []
    @escape_code = INACTIVE
  end

  def display_screen(all_input)
    reset_screen
    parse_input(all_input)
    get_screen_contents.each { |line| puts line }
  end

  private
  def get_screen_contents
    @screen.dup.map do |line|
      (line || []).map { |char| char || ' ' }.join
    end
  end

  def handle_key_strokes(pipe, read_thread)
    return if @key_strokes == []
    read_thread['clear'] = true
    key_stroke = @key_strokes.shift
    stroke_class = key_stroke.class.to_s
    p "pressing #{key_stroke} which is a #{stroke_class}"
    pipe.puts(key_stroke) if stroke_class == 'String'
    pipe.putc(key_stroke) if stroke_class == 'FixNum'
  end

  def parse_input(input)
    input.each_byte do |byte|
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
end

def handle_read(pipe)
  Thread.current[:output] = ''
  Thread.current[:clear] = false
  until pipe.eof?
    current_char = pipe.getc
    Thread.current[:output] = '' if Thread.current[:clear]
    Thread.current[:output] += current_char
    Thread.current[:clear] = false
  end
end

def take_screen_shot(all_input)
  File.open('screenshot', 'w') do |f|
    all_input.dup.each_byte do |byte|
      f.putc(byte)
    end
    f.putc(27)
    f.puts('[50;0H')
  end
end

# read a character without pressing enter and without printing to the screen
def read_char
  begin
    # save previous state of stty
    old_state = `stty -g`
    # disable echoing and enable raw (not having to press enter)
    system "stty raw -echo"
    c = STDIN.getc.chr
    # gather next two characters of special keys
    if(c=="\e")
      extra_thread = Thread.new{
        c = c + STDIN.getc.chr
        c = c + STDIN.getc.chr
      }
      # wait just long enough for special keys to get swallowed
      extra_thread.join(0.00001)
      # kill thread so not-so-long special keys don't wait on getc
      extra_thread.kill
    end
  rescue => ex
    puts "#{ex.class}: #{ex.message}"
    puts ex.backtrace
  ensure
    # restore previous state of stty
    system "stty #{old_state}"
  end
  return c
end

IO.popen('crawl -name Player -species Human -background Summoner 2> error', "w+") do |pipe|
  read_thread = Thread.fork {handle_read(pipe)}

  while true
    sleep(1)
    take_screen_shot(read_thread[:output])
    TerminalEmulator.new.display_screen(read_thread[:output])
    blah = read_char
    blah.each_byte do |byte|
      p byte
      pipe.putc byte
    end
    #read_char.each_byte
    #pipe.puts read_char
  end
end
