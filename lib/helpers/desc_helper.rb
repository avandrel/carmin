module Carmin
	class DescHelper
		def self.create_desc(params, description)
			desc = {}
			desc[:source] = params['source']
			desc[:channel] = params['channel']
			desc[:description] = description unless description.blank?
			desc[:created] = DateTime.now
			desc.to_json
		end

		private

	end
end