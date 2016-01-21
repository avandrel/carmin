module Carmin
	class Config
		def self.get_config_hash
			config_hash = {}
			if ENV['RACK_ENV'] != 'production'
				config_hash = YAML.load(File.read("config.yml"))
			else
				config_hash = self.get_config_from_env
			end
			config_hash
		end

		private

		def self.get_config_from_env
			config_hash = {}

			config_hash['trello_developer_public_key'] = ENV['TRELLO_DPK']
			config_hash['trello_member_token'] = ENV['TRELLO_MT']
			config_hash['trello_username'] = ENV['TRELLO_U']
			config_hash['trello_board_id'] = ENV['TRELLO_BI']
			config_hash['trello_board_url'] = ENV['TRELLO_BU']

			config_hash['discourse_url'] = ENV['DISCOURSE_U']
			config_hash['discourse_api_key'] = ENV['DISCOURSE_AK']
			config_hash['discourse_api_username'] = ENV['DISCOURSE_AU']
			config_hash['discourse_publish_topic_id'] = ENV['DISCOURSE_PTI']
			config_hash['discourse_publish_token'] = ENV['DISCOURSE_PT']

			config_hash['slack_wywiad_incoming_hooks'] = ENV['SLACK_WIH']
			config_hash['slack_wywiad_outgoing_token'] = ENV['SLACK_WOT']
			
			config_hash['ff_plugin_token'] = ENV['FF_PT']
			config_hash['chrome_plugin_token'] = ENV['CHROME_PT']

			config_hash['mongo_user'] = ENV['MONGO_U']
			config_hash['mongo_password'] = ENV['MONGO_P']

			config_hash['healthcheck_token'] = ENV['HEALTHCHECK_T']
			config_hash['dispatch_token'] = ENV['DISPATCH_T']
			config_hash['add_recipient_token'] = ENV['ADDR_T']
			config_hash['search_token'] = ENV['SEARCH_T']
			
			config_hash['mail_smtp_server'] = ENV['MAIL_S']
			config_hash['mail_smtp_port'] = ENV['MAIL_PO']
			config_hash['mail_smtp_user'] = ENV['MAIL_U']
			config_hash['mail_smtp_password'] = ENV['MAIL_PA']

			config_hash['admin_email'] = ENV['ADMIN_E']
			
			config_hash['emails'] = {}
			config_hash['emails']['finanseibudet'] = ENV['finanseibudet']
			config_hash['emails']['kultura'] = ENV['kultura']
			config_hash['emails']['lgbt'] = ENV['lgbt']
			config_hash['emails']['naukaiszkolnictwowysze'] = ENV['naukaiszkolnictwowysze']
			config_hash['emails']['obszarywiejskieirolnictwo'] = ENV['obszarywiejskieirolnictwo']
			config_hash['emails']['ochronaprawzwierzt'] = ENV['ochronaprawzwierzt']
			config_hash['emails']['ochronaprzyrody'] = ENV['ochronaprzyrody']
			config_hash['emails']['owiataiedukacja'] = ENV['owiataiedukacja']
			config_hash['emails']['politykamieszkaniowa'] = ENV['politykamieszkaniowa']
			config_hash['emails']['politykaprzestrzenna'] = ENV['politykaprzestrzenna']
			config_hash['emails']['politykaspoeczna'] = ENV['politykaspoeczna']
			config_hash['emails']['politykazagraniczna'] = ENV['politykazagraniczna']
			config_hash['emails']['prawakobiet'] = ENV['prawakobiet']
			config_hash['emails']['razemwmediach'] = ENV['razemwmediach']
			config_hash['emails']['wieckiepastwo'] = ENV['wieckiepastwo']
			config_hash['emails']['ustrjpastwaisamorzd'] = ENV['ustrjpastwaisamorzd']
			config_hash['emails']['zdrowie'] = ENV['zdrowie']

			config_hash
		end
	end
end

