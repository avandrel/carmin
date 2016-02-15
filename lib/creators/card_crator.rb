# encoding UTF-8

require 'trello'
require 'link_thumbnailer'
require 'whatlanguage'

module Carmin
	class CardCreator
		INBOX_LIST_NAME = "Inbox"

		ISO_CODES = {
		    nil => nil,
		    :arabic => :ar,
		    :danish => :da,
		    :dutch  => :nl,
		    :english => :en,
		    :farsi => :fa,
		    :finnish => :fi,
		    :french => :fr,
		    :german => :de,
		    :greek => :el,
		    :hebrew => :he,
		    :hungarian => :hu,
		    :italian => :it,
		    :korean => :ko,
		    :norwegian => :no,
		    :pinyin => :zh,
		    :polish => :pl,
		    :portuguese => :pt,
		    :russian => :ru,
		    :spanish => :es,
		    :swedish => :sv
		  }

		  USER_AGENTS = [
		  	'facebookexternalhit/1.1'
		  ]

		def initialize(config_hash, card_repository)
			Trello.configure do |config|
          		config.developer_public_key = config_hash["trello_developer_public_key"]
          		config.member_token = config_hash["trello_member_token"]
        	end
	        @wywiad_board = Trello::Board.find(config_hash["trello_board_id"])
			@error_message = ''
			@card = nil
			@card_repository = card_repository
			@card_helper = Carmin::CardHelper.new config_hash
		end

		def try_create_inbox_card(params)
			title = ''
			description = ''
			images = []

			begin
				page = LinkThumbnailer.generate(params['link'], user_agent: USER_AGENTS.sample)
				puts page.inspect
				title = page.title
				images = page.images
				description = page.description
				language = language_iso(WhatLanguage.new(:english, :german, :french, :spanish, :polish).language(title.to_s))
			rescue => ex
            	puts ex.message
				title = params['link']
			end

			if is_unique?(params['link'])				
				desc = Carmin::DescHelper.create_desc(params, description)
				create_card(INBOX_LIST_NAME, title, desc)
				add_checklist()
				add_attachments(images, params['link'])
				if !language.blank?
					add_language_label(language)
				end
				@card_repository.add_card(@card)
				return true
			else
				@error_message = 'Takie zgłoszenie już istnieje!'
				return false
			end
		end

=begin
		def create_group_card(group, message)
			if is_unique?(group, message)
				create_card(group, message)
			end
		end
=end

		def error_message
			@error_message
		end

		def card
			@card
		end

		private

  		def language_iso(text)
    		ISO_CODES[text]
  		end

		def is_unique?(url)
			!@card_repository.card_in_repo?(url)
		end

		def get_list_by_name(list_name)
			@wywiad_board.lists.first { |list| list.name = list_name}
		end

		def create_card(list_name, message, desc_json)
       		@card = Trello::Card.create({
            	:list_id => get_list_by_name(list_name).id,
            	:name => message,
            	:desc => desc_json
          		})
       		@card.save
		end

		def add_checklist
			checklist = Trello::Checklist.create({
				:name => "Postęp",
				:card_id => @card.id,
				:board_id => @card.board_id,
				:list_id => @card.list_id
				})
			checklist.add_item("DONE")
			checklist.save
		end

		def add_attachments(images, url)
			if !images.empty?
				#@card.add_attachment(images.first.to_s)
			end
			@card.add_attachment(url, "url")
		end

		def add_language_label(language)
			puts language
			label = @card_helper.board_labels.select{ |label| label.color == "red" && label.name == language.to_s}.first
			if !label.nil?
				@card.add_label(label)
			end
		end
	end
end