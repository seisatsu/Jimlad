#  Jimlad Bot for DKMU (jimlad.rb)
#  Written by Sei Satzparad
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#  TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.

require 'discordrb'
require 'marky_markov'

bot_token = File.read("token.cfg").chomp # Loads bot token from token.cfg
markov = MarkyMarkov::Dictionary.new('dictionary') # Saves/opens dictionary.mmd

# Here we instantiate a `CommandBot` instead of a regular `Bot`, which has the functionality to add commands using the
# `command` method. We have to set a `prefix` here, which will be the character that triggers command execution.
bot = Discordrb::Commands::CommandBot.new token: bot_token, prefix: '!'

# The `mention` event is called if the bot is *directly mentioned*, i.e. not using a role mention or @everyone/@here.
# For now, spit out 10 words when mentioned.
bot.mention do |event|
  event.respond(markov.generate_n_words 10)
  puts markov.generate_n_words 10
end

# Save every message into the dictionary, and also print it to the console.
bot.message do |event|
  markov.parse_string(event.message.content)
  puts event.message.content
  markov.save_dictionary!
end

bot.run
