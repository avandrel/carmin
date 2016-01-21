module Carmin
	class Searcher

		def initialize(config_hash)
			@config_hash = config_hash
			@slack_helper = Carmin::SlackHelper.new @config_hash['slack_wywiad_incoming_hooks'], @config_hash['trello_board_url']
			@card_helper = Carmin::CardHelper.new @config_hash
			@return_message = ''
			@date = DateTime.now.strftime("%F")
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

			card_repository.get_cards_with_label(params['color'], params['name'])			
		end
	end
end