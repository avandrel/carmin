module Carmin
	class Dispatcher

		KOSZ_LIST_NAME = "KOSZ"

		def initialize(config_hash)
			@config_hash = config_hash
			@slack_helper = Carmin::SlackHelper.new @config_hash['slack_wywiad_incoming_hooks'], @config_hash['trello_board_url']
			@card_helper = Carmin::CardHelper.new @config_hash
			@return_message = ''
		end

		def dispatch(params)

			token_helper = Carmin::TokenHelper.new @config_hash
			if !token_helper.try_set_channel(params)
				return 401
			end

			closed_cards_per_list = @card_helper.get_closed_cards_per_list

			mongo_helper = Carmin::MongoHelper.new @config_hash
			card_repository = Carmin::CardRepository.new mongo_helper

			lists_txt_collection = {}
			closed_cards_per_list.each do |list_name, cards|
				puts list_name
				puts cards.map { |card| card.name }.join("\n")
				cards_txt_collection = {}
				cards.each do |card|
					update_desc(card, list_name)
					set_defaults(card)
					range = Carmin::EmailHelper.get_label_value(card, "green")
					(cards_txt_collection[range] ||= []) << Carmin::EmailHelper.create_card_txt(card)
				end

				lists_txt_collection[list_name] = Carmin::EmailCreator.create(list_name, cards_txt_collection)
				#

				#cards.each do |card| 
				#	card_repository.update_card(card)
					#card.delete
				#end
			end

			Carmin::EmailHelper.send_email(@config_hash, lists_txt_collection)

			closed_cards_per_list.values.each do |cards| 
				cards.each do |card|
					card_repository.update_card(card)
					card.delete
				end
			end

			lists_txt_collection
		end

		private

		def update_desc(card, list_name)
			desc = JSON.parse(card.desc)
			desc['list_name'] = list_name
			card.desc = desc
		end

		def set_defaults(card)
			if !card.labels.any? { |label| label.color == "red" }
				label = @card_helper.board_labels.select{ |label| label.color == "red" && label.name == "pl"}.first
				card.add_label(label)
			end

			if !card.labels.any? { |label| label.color == "orange" }
				label = @card_helper.board_labels.select{ |label| label.color == "orange" && label.name == "tekst"}.first
				card.add_label(label)
			end
		end
	end
end