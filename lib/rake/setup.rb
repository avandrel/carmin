require 'trello'
require 'yaml'

module DiTrello
	class Setup
		def initialize
		    config_hash = DiTrello::Config.get_config_hash

		    Trello.configure do |config|
		        config.developer_public_key = config_hash["trello_developer_public_key"]
		        config.member_token = config_hash["trello_member_token"]
		    end

		    board = Trello::Board.find(config_hash["trello_board_id"])

		    clear_lists(board.lists)

		  	create_list(board, "GEdukacja")
		  	create_list(board, "ZO")
		  	create_list(board, "RO")
		  	create_list(board, "Inbox")
		end

		def clear_lists(lists)
			lists.each do |list|
				list.close!
				puts list.methods
			end
		end

		def create_list(board, list_name)
			if !board.lists.any? { |list| list.name == list_name}
				list = Trello::List.create({
		    		:name => list_name,
	    			:board_id => board.id
	    			})
	    		list.save
	    	end
		end
	end
end	