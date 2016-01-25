module Carmin
	class Searcher

		def initialize(config_hash)
			@config_hash = config_hash
			@slack_helper = Carmin::SlackHelper.new @config_hash['slack_wywiad_incoming_hooks'], @config_hash['trello_board_url']
			@card_helper = Carmin::CardHelper.new @config_hash
		end

		def search(params)
			log = []
			log << "# Start"
			start_time = Time.now
			token_helper = Carmin::TokenHelper.new @config_hash
			if !token_helper.validate_token('search', params['token'])
				return 401
			end

			mongo_helper = Carmin::MongoHelper.new @config_hash
			card_repository = Carmin::CardRepository.new mongo_helper

			cards_with_label = card_repository.get_cards_with_label(params['color'], params['text'])			
			cards_in_category = card_repository.get_cards_in_category(params['text'])			

			cards = cards_with_label | cards_in_category

			if params.include?('response_url')
				if cards.count > 0
					@slack_helper.message_to_response(create_message(cards, params['text']), "ok")
				else
					@slack_helper.message_to_response("*#{params['text']} - nie ma takiego tematu!*", "error")
				end				
			else
				cards
			end
		end

		private
		def create_message(cards, label)
			message = "*#{label}*\n"
			cards.take(20).each do |card|
				message << "#{card['last_activity_date'].strftime("%F")} <#{card['source_url']}|#{card['name']}>\n"
			end
			message
		end
	end
end