module DiTrello
	class DescHelper
		def self.create_desc(params)
			desc = {}
			desc[:source] = params['source']
			desc[:channel] = params['channel']
			desc.to_json
		end

		private

	end
end