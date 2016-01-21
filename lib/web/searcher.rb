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

			cards = card_repository.get_cards_with_label(params['color'], params['text'])			

			if params.include?('response_url')
				message = create_message(cards, params['text'])
				puts message
				@slack_helper.message_to_response(message, "ok")
			else
				cards
			end
		end

		private
		def create_message(cards, label)
			message = "*#{label}*\n"
			cards.each do |card|
				message << "#{card['last_activity_date'].strftime("%F")} <#{card['source_url']}|#{card['name']}>\n"
			end
			message
		end
	end
end