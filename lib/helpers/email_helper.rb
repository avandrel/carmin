require 'net/smtp'

module DiTrello
	class EmailHelper
		def self.send_email(config, recipient, group_name, message)
			email = create_message(recipient, group_name, message)

			Net::SMTP.start(config['mail_smtp_server'], 
                config['mail_smtp_port'], 
                'ditrello.mgpm.pl', 
                config['mail_smtp_user'], config['mail_smtp_password']) do |smtp|
			  smtp.send_message email, 'ditrello@mgpm.pl', recipient
			end
		end

		private

		def self.create_message(recipient, group_name, message)
			"From: Razem's DiTrello <ditrello@mgpm.pl>\nTo: <#{recipient}>\nSubject: DiTrello message for group #{group_name}\n\n#{message}"
		end
	end
end