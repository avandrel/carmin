# encoding UTF-8

module Carmin
	class RecipientCreator
		def initialize(config_hash)
			@config_hash = config_hash
			mongo_helper = Carmin::MongoHelper.new @config_hash
			@recipient_repository = Carmin::RecipientRepository.new mongo_helper
		end

		def create(params)
			token_helper = Carmin::TokenHelper.new @config_hash
			if !token_helper.validate_token('add', params['comment'])
				return token_helper.invalid_token
			end

			recipient = create_recipient(params)
			if is_unique?(recipient[:email])
				@recipient_repository.add_recipient(recipient)
				return [201, "#{recipient[:email]} added!"]
			else
				@recipient_repository.update_recipient(recipient)
				return [200, "#{recipient[:email]} updated!"]
			end
		end

		private

		def is_unique?(email)
			!@recipient_repository.recipient_in_repo?(email)
		end

		def create_recipient(params)
			recipient = {}
			recipient[:email] = params['recipients_email']
			recipient[:groups] = params.select { |key, value| key != 'recipients_email'}
			recipient
		end
	end
end