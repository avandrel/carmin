require 'net/smtp'

module Carmin
	class EmailHelper
		def self.send_email(config, recipient, group_name, message)
			email = create_message(recipient, group_name, message)

			Net::SMTP.start(config['mail_smtp_server'], 
                config['mail_smtp_port'], 
                'Carmin.mgpm.pl', 
                config['mail_smtp_user'], config['mail_smtp_password']) do |smtp|
			  smtp.send_message email, 'Carmin@mgpm.pl', recipient
			end
		end

		private

		def self.create_message(recipient, group_name, message)
			"From: Razem's Carmin <Carmin@mgpm.pl>\nTo: <#{recipient}>\nSubject: Carmin message for group #{group_name}\n\n#{message}"
		end
	end
end