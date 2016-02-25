require 'mongo'

module Carmin
	class BodyRepository
		def initialize(mongo_helper)
			@mongo_helper = mongo_helper
		end

		def body_in_repo?(date)
			puts date
            @mongo_helper.body_collection.find({:date => "#{date}"}).first() != nil
        end

        def get_body(date)
        	@mongo_helper.body_collection.find({:date => "#{date}"}).first()
        end
        
        def get_newest_body()
            @mongo_helper.body_collection.find().sort(:_id => -1).first()
        end

		def add_body(body)
        	@mongo_helper.body_collection.insert_one(body)
        end

        def update_body(body)
        	@mongo_helper.body_collection.update_one({:date => "#{body[:date]}"}, body)
        end
	end
end