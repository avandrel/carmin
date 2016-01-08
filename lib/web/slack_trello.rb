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
			puts params.to_json
			if !validate_token(params['token'])
				#return get_message('Błędny token!')
			end

			input_reader = DiTrello::InputReader.new params['text']
			input_reader.read()

			if !input_reader.error_message.empty?
				return @message_helper.return_error_message(params['user_name'], input_reader.error_message)
			end

			@card_helper.create_inbox_card(input_reader.link)
			if !@card_helper.error_message.empty?
				return @message_helper.return_error_message(params['user_name'], @card_helper.error_message)
			else
				return @message_helper.return_ok_message(params['user_name'])
			end

=begin
			if !input_reader.groups.blank?
				input_reader.groups.each do |group|
					@card_helper.create_group_card(group, input_reader.link)
				end
				return @message_helper.return_ok_message(params['user_name'])
			end
=end

		end

		private

		def validate_token(token)
			@config_hash['slack_wywiad_outgoing_token'] == token
		end
	end
end