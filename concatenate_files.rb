
File.open("input.txt",  "w+") do |concatenated_file|
  Dir.glob("hw3data/*").each do |file|
    File.open(file) { |f| concatenated_file.puts f.read }
  end
end

