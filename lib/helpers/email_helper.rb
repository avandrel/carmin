# encoding UTF-8

require 'mail'

module Carmin
	class EmailHelper

		def self.send_email(config_hash, body, email)
			Mail.defaults do
 				delivery_method :smtp, address: config_hash['mail_smtp_server'], port: config_hash['mail_smtp_port'], user_name: config_hash['mail_smtp_user'], password: config_hash['mail_smtp_password'], openssl_verify_mode: "none"
			end

			recipients = email
			subject = create_subject()

			mail = Mail.new do
			  from    'carmin@mgpm.pl'
			  bcc      recipients
			  subject subject
			  body    body
			end

			mail.deliver
		end

		private

		def self.create_subject()
			"Informacje CARMIN z #{DateTime.now.strftime("%F %H:%M")}"
		end

		def self.create_message(recipient, group_name, message)
			"From: CARMIN <carmin@mgpm.pl>\nTo: #{recipient}\nSubject: CARMIN message for list: #{group_name}\n\n#{message}"
		end
	end
end