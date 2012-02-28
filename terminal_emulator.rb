class TerminalEmulator
  def execute_program(command, sleep_delay, &block)
    IO.popen(command + ' 2> error', "w+") do |pipe|
      @read_thread = Thread.fork {handle_read(pipe)}

      while true
        sleep(sleep_delay)
        block.call(pipe, @read_thread[:output])
      end
    end
  end

  def manual_control(pipe)
    input_data(pipe, read_char)
  end

  def input_data(pipe, read_chars)
    read_chars.each_byte do |byte|
      pipe.putc byte
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

  private
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
end
