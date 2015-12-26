# encoding UTF-8

require 'trello'
require 'slack-notifier'

module DiTrello
	class SlackTrello
		def initialize(inbox_list)
			@config_hash = DiTrello::Config.get_config_hash
			@inbox_list = inbox_list
		end

		def respond(params)
			if !validate_token(params['token'])
				#return get_message('Błędny token!')
			end

			raw_input = params['text'].sub(params['trigger_word'], "").strip
			trello_result = create_card(raw_input, params['user_name'])
			get_message(trello_result)
		end

		private

		def validate_token(token)
			@config_hash['slack_wywiad_outgoing_token'] == token
		end

		def create_card(message, user_name)
			if !@inbox_list.cards.any? { |card| card.name == message}
          		card = Trello::Card.create({
            	:list_id => @inbox_list.id,
            	:name => message
          		})
          		card.save
          		notify()
          		return create_ok_message(user_name)
          	else
          		return create_already_exists_message(user_name)
        	end
		end

		def notify()
			notifier = Slack::Notifier.new @config_hash["slack_wywiad_incoming_hooks"]
			message = "New Inbox message! => <#{@config_hash["trello_board_url"]}|Visit Trello board>"
			notifier.ping message
		end

		def create_ok_message(user)
			"#{user}: Dziękujemy zagłoszenie!"
		end

		def create_already_exists_message(user)
			"#{user}: *Takie zgłoszenie już istnieje!*"
		end

		def get_message(message)
			{ "text" => message }.to_json
		end
	end
end