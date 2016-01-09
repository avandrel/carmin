# encoding UTF-8

require 'trello'

module DiTrello
	class CardCreator
		INBOX_LIST_NAME = "Inbox"

		def initialize(config_hash, card_repository)
			Trello.configure do |config|
          		config.developer_public_key = config_hash["trello_developer_public_key"]
          		config.member_token = config_hash["trello_member_token"]
        	end
	        @wywiad_board = Trello::Board.find(config_hash["trello_board_id"])
			@error_message = ''
			@card = nil
			@card_repository = card_repository
		end

		def try_create_inbox_card(params)
			if is_unique?(params['link'])
				desc = DiTrello::DescHelper.create_desc(params)
				create_card(INBOX_LIST_NAME, params['link'], desc)
				add_checklist()
				@card_repository.add_card(@card)
				return true
			else
				@error_message = 'Takie zgłoszenie już istnieje!'
				return false
			end
		end

=begin
		def create_group_card(group, message)
			if is_unique?(group, message)
				create_card(group, message)
			end
		end
=end

		def error_message
			@error_message
		end

		def card
			@card
		end

		private

		def is_unique?(message)
			!@card_repository.card_in_repo?(message)
		end

		def get_list_by_name(list_name)
			@wywiad_board.lists.first { |list| list.name = list_name}
		end

		def create_card(list_name, message, desc_json)
       		@card = Trello::Card.create({
            	:list_id => get_list_by_name(list_name).id,
            	:name => message,
            	:desc => desc_json
          		})
       		@card.save
		end

		def add_checklist
			checklist = Trello::Checklist.create({
				:name => "Postęp",
				:card_id => @card.id,
				:board_id => @card.board_id,
				:list_id => @card.list_id
				})
			checklist.add_item("DONE")
			checklist.save
		end
	end
end