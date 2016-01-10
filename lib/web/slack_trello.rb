# encoding UTF-8

require 'slack-notifier'

module Carmin
	class SlackTrello
		def initialize(config_hash)
			@config_hash = config_hash
			@slack_helper = Carmin::SlackHelper.new @config_hash['slack_wywiad_incoming_hooks'], @config_hash['trello_board_url']
			@return_message = ''
		end

		def respond(params)
			token_helper = Carmin::TokenHelper.new @config_hash
			if !token_helper.try_set_channel(params)
				return @slack_helper.return_user_error_message(params['user_name'], token_helper.error_message)
			end

			input_reader = Carmin::InputReader.new
			if !input_reader.try_read(params)
				return @slack_helper.return_user_error_message(params['user_name'], input_reader.error_message)
			end

			mongo_helper = Carmin::MongoHelper.new @config_hash
			card_repository = Carmin::CardRepository.new mongo_helper
			card_creator = Carmin::CardCreator.new(@config_hash, card_repository)
			if card_creator.try_create_inbox_card(params)
				@return_message = @slack_helper.return_user_ok_message(params['user_name'])
			else
				return @slack_helper.return_user_error_message(params['user_name'], card_creator.error_message)
			end


=begin
			if !input_reader.groups.blank?
				input_reader.groups.each do |group|
					@card_creator.create_group_card(group, input_reader.link)
				end
				return @slack_helper.return_user_ok_message(params['user_name'])
			end
=end
			@return_message
		end

		private

		def validate_token(token)
			@config_hash['slack_wywiad_outgoing_token'] == token
		end
	end
end