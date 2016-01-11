module Carmin
	class CardHelper

		INBOX_LIST_NAME = "INBOX"
		SEC_IN_HOUR = 3600

		def initialize(config_hash)
			Trello.configure do |config|
          		config.developer_public_key = config_hash["trello_developer_public_key"]
          		config.member_token = config_hash["trello_member_token"]
        	end
	        @wywiad_board = Trello::Board.find(config_hash["trello_board_id"])
			@error_message = ''
		end

		def get_out_of_date_cards(hours)
			[out_of_date_cards(hours).count, @wywiad_board.cards.count]
		end

		def get_list_names_with_too_much_cards(card_count)
			[list_names_with_too_much_cards(card_count).count, @wywiad_board.lists.count]
		end

		def get_closed_cards_per_list
			closed_cards_per_group = {}
			@wywiad_board.lists.select { |list| list.name != INBOX_LIST_NAME }.each do |list|
				cards = get_closed_cards_in_list(list.cards)
				if cards.count > 0
					closed_cards_per_group[list.name] = cards
				end
			end
			closed_cards_per_group
		end

		def get_cards_from_trash(trash_group_name)
			@wywiad_board.lists.select { |list| list.name == trash_group_name }.first.cards
		end

		private

		def out_of_date_cards(hours)
			@wywiad_board.cards.select { |card| (DateTime.now.to_time - card.last_activity_date.to_time) > hours * SEC_IN_HOUR}
		end

		def list_names_with_too_much_cards(card_count)
			@wywiad_board.lists.select{ |list| list.cards.count > card_count }.map { |list| list.name }
		end

		def get_closed_cards_in_list(cards)
			cards.select { |card| is_card_closed?(card)}
		end

		def is_card_closed?(card)
			has_label?("green", card.labels) &&
			card.badges['checkItems'] == card.badges['checkItemsChecked']
		end

		def has_label?(color, labels)
			labels.any? { |label| label.color == color }
		end
	end
end