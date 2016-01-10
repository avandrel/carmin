module Carmin
	class HealthCheck

		OOD_HOURS = 72
		TMC_COUNT = 15

		def initialize(config_hash)
			@config_hash = config_hash
			@slack_helper = Carmin::SlackHelper.new @config_hash['slack_wywiad_incoming_hooks'], @config_hash['trello_board_url']
			@card_helper = Carmin::CardHelper.new @config_hash
			@return_message = ''
		end

		def check(params)

			token_helper = Carmin::TokenHelper.new @config_hash
			if !token_helper.try_set_channel(params)
				return 401
			end

			cards_out_of_date = @card_helper.get_out_of_date_cards(OOD_HOURS)
			@return_message << "OOD: #{cards_out_of_date[0]}/#{cards_out_of_date[1]} "
			lists_with_too_much_cards = @card_helper.get_list_names_with_too_much_cards(TMC_COUNT)
			@return_message << "TMC_COUNT: #{lists_with_too_much_cards[0]}/#{lists_with_too_much_cards[1]} "

			@slack_helper.notify(@return_message)
			200
		end
	end
end