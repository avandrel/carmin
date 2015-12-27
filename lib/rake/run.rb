require 'discourse_api'
require 'slack-notifier'
require 'trello'
require 'yaml'

module DiTrello
	class Run
		def initialize
		    @config_hash = DiTrello::Config.get_config_hash
		    notify_counter = 0

		    Trello.configure do |config|
		        config.developer_public_key = @config_hash["trello_developer_public_key"]
		        config.member_token = @config_hash["trello_member_token"]
		    end

		    board = Trello::Board.find(@config_hash["trello_board_id"])
		    puts board
	        inbox_list =  board.lists.first { |list| list.name = "Inbox"}
	        puts inbox_list
      
=begin
			client = DiscourseApi::Client.new(@config_hash["discourse_url"])
      		client.api_key = @config_hash["discourse_api_key"]
      		client.api_username = @config_hash["discourse_api_username"]

      		messages = client.private_messages(client.api_username)
      		#puts messages.to_json
      		messages.each do |message|
        		create_card(inbox_list, message)
      		end

      		if notify_counter > 0
      			notify(notify_counter)
      		end
=end

		end

		def create_card(list, message)
			if !list.cards.any? { |card| card.name == message["title"]}
          		card = Trello::Card.create({
            	:list_id => list.id,
            	:name => message["title"]
          		})
          		self.notify_counter += 1
          		card.save          		
        	end
		end

		def notify(notify_counter)
			notifier = Slack::Notifier.new @config_hash["slack_wywiad_incoming_hooks"]
			message = "New Inbox message count: #{notify_counter} => <#{@config_hash["trello_board_url"]}|Trello board>"
			notifier.ping message
		end
	end
end	