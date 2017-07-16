begin
  loop do
    if rand < 0.2
      puts "GOOSE!"
      break
    end
    puts "duck"
    sleep 1
  end
ensure
  puts "clean up script!"
end
