require 'discourse_api'
require 'slack-notifier'
require 'trello'
require 'yaml'

module Carmin
	class Run
		def initialize
		    @config_hash = Carmin::Config.get_config_hash

		    Trello.configure do |config|
		        config.developer_public_key = @config_hash["trello_developer_public_key"]
		        config.member_token = @config_hash["trello_member_token"]
		    end

		    board = Trello::Board.find(@config_hash["trello_board_id"])

		    board.lists.each do |list|
		    	if list.name != "Inbox" && list.cards.size > 0
		    		message_array = []
		    		list.cards.map { |card| message_array << card.name }
		    		Carmin::EmailHelper.send_email(@config_hash, "avandrel@mgpm.pl", list.name, message_array.join("\n"))
		    		list.cards.each { |card| card.delete }
		    	end
		    end
		end
	end
end	