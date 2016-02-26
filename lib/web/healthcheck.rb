module Carmin
	class HealthCheck

		OOD_HOURS = 72
		TMC_COUNT = 15
		KOSZ_LIST_NAME = "KOSZ"

		def initialize(config_hash)
			@config_hash = config_hash
			@slack_helper = Carmin::SlackHelper.new @config_hash['slack_wywiad_incoming_hooks'], @config_hash['trello_board_url']
			@card_helper = Carmin::CardHelper.new @config_hash
			@return_message = ''
		end

		def check(params)
			token_helper = Carmin::TokenHelper.new @config_hash
			if !token_helper.validate_token('healthcheck', params['token'])
				return 401
			end

			mongo_helper = Carmin::MongoHelper.new @config_hash
			body_repository = Carmin::BodyRepository.new mongo_helper
			body = body_repository.get_newest_body()
			hours = ((Time.now - body['_id'].generation_time) / 3600).round
			@return_message << "Od odstatniej wysyłki minęło około *#{hours}h*\n"
			
			card_repository = Carmin::CardRepository.new mongo_helper
			
			cards_out_of_date = @card_helper.get_out_of_date_cards(OOD_HOURS)
			@return_message << "Zgłoszenia przeterminowane: *#{cards_out_of_date[0]}/#{cards_out_of_date[1]}*\n"
			cards_in_trash = @card_helper.get_cards_from_trash(KOSZ_LIST_NAME)
			trash_message = "Liczba zgłoszeń usuniętych z kosza: *#{cards_in_trash.count}*"

			cards_in_trash.each do |card|
				desc = JSON.parse(card.desc)
				desc['list_name'] = card.list.name
				card.desc = desc
				card_repository.update_card(card)
				card.delete
			end

			cards_not_done = @card_helper.get_not_done_cards
			@return_message << "Zgłoszenia zakończone: *#{cards_not_done[0]}/#{cards_not_done[1]}*\n"
			@return_message << trash_message

			@slack_helper.notify(@return_message)
			200
		end
	end
end