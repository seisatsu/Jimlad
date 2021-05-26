#  Jimlad Bot Feeding Program for DKMU (munch.rb)
#  Written by Sei Satzparad
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#  TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.

require 'marky_markov'
require 'iconv' unless String.method_defined?(:encode)

markov = MarkyMarkov::Dictionary.new('dictionary') # Saves/opens dictionary.mmd

# Eat all of the files in the texts directory.
Dir.foreach('texts/') do |filename|
  next if filename == '.' or filename == '..'
  print "Eating #{filename}... "
  
  # Read in a file.
  file_contents = File.read("texts/"+filename)
  
  # Iron out file encoding issues.
  if String.method_defined?(:encode)
    file_contents.encode!('UTF-8', 'UTF-8', :invalid => :replace)
  else
    ic = Iconv.new('UTF-8', 'UTF-8//IGNORE')
    file_contents = ic.iconv(file_contents)
  end
  
  # Parse the file contents line by line.
  print "Digesting file... "
  file_contents.gsub!(/\r\n?/, "\n")
  file_contents.each_line do |line|
    next if line.chomp == ""
    markov.parse_string(line)
  end
  
  # Update the dictionary.
  markov.save_dictionary!
  puts "Done."
end

# Save and exit.
puts "Gochisousama deshita!"

