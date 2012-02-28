def handle_input
  Thread.current[:keystrokes] = []
  File.open('input', 'w') do |f|
    while true
      sleep(0.1)
      if Thread.current[:keystrokes] != []
        byte = Thread.current[:keystrokes].shift
        f.putc(byte)
      end
    end
  end
end

def handle_output
  file = File.open('output', 'r')
  while (char = file.getc)
    print char
  end
end

in_thread = Thread.fork { handle_input }
program_thread = Thread.fork do
  IO.popen('crawl -name Player -species Human -background Summoner < input > output 2>&1', "w+") do |pipe|
    while true
      sleep(0.5)
    end
  end
end
read_thread = Thread.fork { handle_output }

while (true)
  sleep(0.5)
  `reset`
  p "asking for input"
  r = gets
  in_thread[:keystrokes] << r
end

#IO.popen('crawl -name Player -species Human -background Summoner < input > output 2>&1', "w+") do |pipe|
  #read_thread = Thread.fork {handle_read(pipe)}

  #while true
    #sleep(1)
    #`reset`
    #take_screen_shot(read_thread['output'])
    #`cat screenshot`
    #p "asking for input"
    #r = gets
    #pipe.puts r
    #pipe.flush
  #end
  #`reset`
#end
