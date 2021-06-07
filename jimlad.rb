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
if(File.exist?("dictionary.mmd.bk"))
  FileUtils.cp("dictionary.mmd.bk", "dictionary.mmd.bk2")
end
FileUtils.cp("dictionary.mmd", "dictionary.mmd.bk")

# Here we instantiate a `CommandBot` instead of a regular `Bot`, which has the functionality to add commands using the
# `command` method. We have to set a `prefix` here, which will be the character that triggers command execution.
bot = Discordrb::Commands::CommandBot.new token: config["token"], prefix: '!'

# The `mention` event is called if the bot is *directly mentioned*, i.e. not using a role mention or @everyone/@here.
bot.mention do |event|
  response = markov.generate_n_words rand(config["min"]..config["max"])
  event.respond(response)
  puts response
end

# Save every message into the dictionary, and also print it to the console.
bot.message do |event|
  markov.parse_string(event.message.content)
  puts event.message.content
  markov.save_dictionary!
end

bot.run
