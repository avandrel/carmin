module Carmin
	class Searcher

		LIST_IDIOMS = ['info', 'lista', 'listy', 'grupy', 'kategorie']

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

			search_phrase = params['text']
			cards = []

			if LIST_IDIOMS.include?(search_phrase)
				if search_list_names(search_phrase)
					cards = search_cards(search_phrase, '', mongo_helper)
				end
			else
				cards = search_cards(search_phrase, params['color'], mongo_helper)
			end

			if params.include?('response_url')
				if cards.count > 0
					@slack_helper.message_to_response(create_message(cards, search_phrase), "ok")
				else
					@slack_helper.message_to_response("*#{search_phrase} - nie ma takiego tematu!*", "error")
				end				
			else
				cards
			end
		end

		private

		def search_cards(search_phrase, color, mongo_helper)
			card_repository = Carmin::CardRepository.new mongo_helper

			cards_with_label = card_repository.get_cards_with_label(color, search_phrase)			
			cards_in_category = card_repository.get_cards_in_category(search_phrase)			

			cards_with_label | cards_in_category			
		end

		def search_list_names(search_phrase)
			Trello.configure do |config|
          		config.developer_public_key = @config_hash["trello_developer_public_key"]
          		config.member_token = @config_hash["trello_member_token"]
        	end
			wywiad_board = Trello::Board.find(@config_hash["trello_board_id"])
			wywiad_board.lists.select{|list| list.name == search_phrase}.count > 0
		end

		def create_message(cards, label)
			message = "*#{label}*\n"
			cards.take(20).each do |card|
				message << "#{card['last_activity_date'].strftime("%F")} <#{card['source_url']}|#{card['name']}>\n"
			end
			message
		end
	end
end