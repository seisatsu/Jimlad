#  Jimlad Bot for DKMU (jimlad.rb)
#  Written by Sei Satzparad
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#  TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.

=begin
                    &@@@@@@%,
                .@@@@@%  .@@@@(
                #@@@@.     %@@@#
                .@@@@@(/*%@@@@#
                   ,#@@@@@@@(
                      &@@@,
    %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
             ..... ..,@@@@(..... ....,,,,.,,
                      &@@@,
                      &@@@,
                      &@@@.
                      #@@@
                      /@@@
                      #@@@
                      %@@@
                      %@@@
                      %@@@
                      %@@@
    @@@@@@@@@@@       /@@&
   /@@@,              %@@@                   @&
   ,@@&               &@@@                 #@@%
    #@@#             (@@@@               ,@@@@,
     ,@@@@(.    ,#@@@@@@@@@@@@@@@@@@@@@@@@@@@@
       .%@@@@@@@@@#,



                         &/                                             
                       *@@@                                             
                      %  @@&                                            
                    (    &  .        (&@/                               
                        .%        &@@@.                                 
                        /%     &%  *.                                   
                        %% (@/                                          
                        @@                                              
                     && @&                                              
                  %@,   @%     /&@@@                                    
               #@@ .#&@@@@#     &&                                      
             /         .@&   ,@%                                        
     %@@(              #@%*@@,                                          
   *@@%                &@@&                 (*                          
                      &@@@@@@@@@@@@@&&&%&%(,,    &#                     
                   .@/                           &@@&%(*                
             /    %                           #                         
            &, ((                                                       
          ,@ &@&&                                                       
        ,@@@&                                                           
       &@.                                                              
     ,   
=end

require 'discordrb'
require 'marky_markov'
require 'json'

config = JSON.parse(File.read("jimlad.cfg")) # Loads the main configuration file

# Load the dictionary.
print "Loading chains... "
start = Time.now
markov = MarkyMarkov::Dictionary.new('dictionary') # Saves/opens dictionary.mmd
finish = Time.now
diff = finish - start
puts "Done in #{diff} seconds."

# Make backups, because sometimes we lose the dictionary if we exit uncleanly.
if File.exist?("dictionary.mmd.bk")
  FileUtils.cp("dictionary.mmd.bk", "dictionary.mmd.bk2")
end
if File.exist?("dictionary.mmd")
  FileUtils.cp("dictionary.mmd", "dictionary.mmd.bk")
end

# Attempt to convert a string to an integer.
def number_or_nil(string)
  Integer(string || '')
rescue ArgumentError
  nil
end

# Here we instantiate a `CommandBot` instead of a regular `Bot`, which has the functionality to add commands using the
# `command` method. We have to set a `prefix` here, which will be the character that triggers command execution.
bot = Discordrb::Commands::CommandBot.new token: config["token"], prefix: '!'

# Set minimum character count.
bot.command :min do |_event, *args|
  break unless config["admin"].include?(_event.user.id)
  number = number_or_nil(args.join(' '))
  if number
    config["min"] = number
    File.open("jimlad.cfg","w") do |f|
      f.write(config.to_json)
    end
    "[[SET CHARACTER MINIMUM TO #{number}]]"
  else
    "[[INVALID ARGUMENT TO !MIN]]"
  end
end

# Set maximum character count.
bot.command :max do |_event, *args|
  break unless config["admin"].include?(_event.user.id)
  number = number_or_nil(args.join(' '))
  if number
    config["max"] = number
    File.open("jimlad.cfg","w") do |f|
      f.write(config.to_json)
    end
    "[[SET CHARACTER MAXIMUM TO #{number}]]"
  else
    "[[INVALID ARGUMENT TO !MAX]]"
  end
end

# Quit.
bot.command :quit do |event|
  break unless config["admin"].include?(event.user.id)
  bot.send_message(event.channel.id, '[[SHUTTING DOWN]]')
  exit
end

# The `mention` event is called if the bot is *directly mentioned*, i.e. not using a role mention or @everyone/@here.
bot.mention do |event|
  response = markov.generate_n_words(rand(config["min"]..config["max"]))
  if not config["wordfilter"].any? { |word| response.include?(word) }
    event.respond(response)
    puts response
  else
    puts "[[WORDFILTER TRIGGERED]]"
  end
end

# Save every message into the dictionary, and also print it to the console.
bot.message do |event|
  if event.channel.type != 1
    if not config["wordfilter"].any? { |word| event.message.content.include?(word) }
      markov.parse_string(event.message.content)
      puts event.message.content
      markov.save_dictionary!
    else
      puts "[[WORDFILTER TRIGGERED]]"
    end
  end
end

bot.run
