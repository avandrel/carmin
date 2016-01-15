require 'mongo'

module Carmin
	class RecipientRepository
		def initialize(mongo_helper)
			@mongo_helper = mongo_helper
		end

		def recipient_in_repo?(email)
			puts email
            @mongo_helper.recipients_collection.find({:email => "#{email}"}).first() != nil
        end

		def add_recipient(recipient)
        	@mongo_helper.recipients_collection.insert_one(recipient)
        end

        def update_recipient(recipient)
        	@mongo_helper.recipients_collection.update_one({:email => "#{recipient[:email]}"}, recipient)
        end

        def get_all_recipients()
        	retval = []
        	@mongo_helper.recipients_collection.find().each { |recipient| retval << recipient }
        	retval
        end
	end
end