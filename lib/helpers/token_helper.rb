module Carmin
	class TokenHelper
		def initialize(config_hash)
			@config_hash = config_hash
			@error_message = ''
		end

		def error_message
			@error_message
		end

		def try_set_channel(params)
			token = params['token']

			case token
				when @config_hash['slack_wywiad_outgoing_token'] then 
					begin
						params['channel'] = "slack" 
						return true
					end
				when @config_hash['ff_plugin_token'] then 
					begin
						params['channel'] = "ff_plugin" 
						return true
					end
				when @config_hash['chrome_plugin_token'] then 
					begin
						params['channel'] = "chrome_plugin" 
						return true
					end
			end

			@error_message = 'Nieprawidłowy kanał zgłoszenia!'
			return false
		end
	end
end