module DiTrello
	class MessageHelper
		def initialize(incoming_hook, board_url)
			@notifier = Slack::Notifier.new incoming_hook
			@board_url = board_url
		end

		def return_error_message(user_name, error_message)
			message = "#{user_name}: *#{error_message}*"
			message_to_response(message)
		end

		def return_ok_message(user)
			message = "#{user}: Dziękujemy zagłoszenie!"
			notify()
			message_to_response(message)
		end

		private

		def notify()
			@notifier.ping "New Inbox message! => <#{@board_url}|Visit Trello board>"
		end

		def message_to_response(message)
			{ "text" => message }.to_json
		end
	end
end