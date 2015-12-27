# encoding UTF-8

require 'trello'

module DiTrello
	class CardHelper
		INBOX_LIST_NAME = "Inbox"

		def initialize(config_hash)
			Trello.configure do |config|
          		config.developer_public_key = config_hash["trello_developer_public_key"]
          		config.member_token = config_hash["trello_member_token"]
        	end
	        @wywiad_board = Trello::Board.find(config_hash["trello_board_id"])
			@error_message = ''
		end

		def create_inbox_card(message)
			if is_unique?(INBOX_LIST_NAME, message)
				create_card(INBOX_LIST_NAME, message)
			else
				@error_message = 'Takie zgłoszenie już istnieje!'
			end
		end

		def create_group_card(group, message)
			if is_unique?(group, message)
				create_card(group, message)
			end
		end

		def error_message
			@error_message
		end

		private

		def is_unique?(list_name, message)
			list = get_list_by_name(list_name)
			if !list.blank?
				!list.cards.any? { |card| card.name == message}
			end
		end

		def get_list_by_name(list_name)
			@wywiad_board.lists.first { |list| list.name = list_name}
		end

		def create_card(list_name, message)
       		card = Trello::Card.create({
            	:list_id => get_list_by_name(list_name).id,
            	:name => message
          		})
       		card.save
		end
	end
end