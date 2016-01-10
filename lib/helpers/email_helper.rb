require 'net/smtp'

module Carmin
	class EmailHelper
		def self.send_email(config_hash, group_name, message)
			recipient = config_hash['emails'][create_recipient_name(group_name)]
			email = create_message(recipient, group_name, message)

			Net::SMTP.start(config_hash['mail_smtp_server'], 
                config_hash['mail_smtp_port'], 
                'carmin.mgpm.pl', 
                config_hash['mail_smtp_user'], config_hash['mail_smtp_password']) do |smtp|
			  smtp.send_message email, 'carmin@mgpm.pl', recipient.split(',')
			end
		end

		private

		def self.create_message(recipient, group_name, message)
			"From: CARMIN <carmin@mgpm.pl>\nTo: #{recipient}\nSubject: CARMIN message for list: #{group_name}\n\n#{message}"
		end

		def self.create_recipient_name(group_name)
			group_name.downcase.gsub(" ", "")
		end
	end
end