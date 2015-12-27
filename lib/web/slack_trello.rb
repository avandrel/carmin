# encoding UTF-8

require 'slack-notifier'

module DiTrello
	class SlackTrello
		def initialize(config_hash)
			@config_hash = config_hash
			@message_helper = DiTrello::MessageHelper.new @config_hash['slack_wywiad_incoming_hooks'], @config_hash['trello_board_url']
			@card_helper = DiTrello::CardHelper.new @config_hash
		end

		def respond(params)
			if !validate_token(params['token'])
				#return get_message('Błędny token!')
			end

			raw_input = params['text'].sub(params['trigger_word'], "").strip
			input_reader = DiTrello::InputReader.new raw_input
			input_reader.read()

			if !input_reader.error_message.empty?
				return @message_helper.retun_error_message(params['user_name'], input_reader.error_message)
			end

			if input_reader.groups.blank?
				@card_helper.create_inbox_card(input_reader.link)
				if !@card_helper.error_message.empty?
					return @message_helper.return_error_message(params['user_name'], @card_helper.error_message)
				else
					return @message_helper.return_ok_message(params['user_name'])
				end
			end
			puts input_reader.inspect
			#trello_result = create_card(raw_input, params['user_name'])
			#get_message(trello_result)
		end

		private

		def validate_token(token)
			@config_hash['slack_wywiad_outgoing_token'] == token
		end

		





		def create_already_exists_message(user)
			"#{user}: *Takie zgłoszenie już istnieje!*"
		end

		def get_message(message)
			{ "text" => message }.to_json
		end
	end
end