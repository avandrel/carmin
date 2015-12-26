module DiTrello
	class SlackTrello
		def initialize
			@config_hash = DiTrello::Config.get_config_hash
		end

		def respond(params)
			if !validate_token(params['token'])
				return get_message('Invalid token!')
			end

			conc_params = ''
	      	params.each do |key,value|
		        if value.is_a? String
	          	conc_params = "#{conc_params}; #{key}: #{value}"
	        	end
	      	end
		end

		private

		def validate_token(token)
			@config_hash['slack_wywiad_outgoing_token'] == token
		end

		def get_message(message)
			{ "text" => message }.to_json
		end
	end
end