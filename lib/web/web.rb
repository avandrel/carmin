require 'sinatra/base'
require 'sinatra/config_file'
require 'haml'
require 'discourse_api'

module Carmin
  class Web < Sinatra::Base
    register Sinatra::ConfigFile

    before do
        @config_hash = Carmin::Config.get_config_hash
    end

    get "/add" do
      card_helper = Carmin::CardHelper.new @config_hash
      @list_names = card_helper.get_list_names
      haml :add_recipient
    end

    get "/healthcheck" do
      healthcheck = Carmin::HealthCheck.new @config_hash
      healthcheck.check(params)
    end

    get "/dispatch" do 
      response['Content-Type'] = 'text/plain'
      dispatcher = Carmin::Dispatcher.new @config_hash
      dispatcher.dispatch(params)
    end

    get "/post" do
      post_creator = Carmin::PostCreator.new @config_hash
      post_creator.create(params)
    end

    post "/add_recipient" do
      recipient_creator = Carmin::RecipientCreator.new @config_hash
      recipient_creator.create(params)
    end


    post "/create" do
      slack_trello = Carmin::SlackTrello.new @config_hash
      slack_trello.respond(params)
    end

    get "/search" do
      searcher = Carmin::Searcher.new @config_hash
      @cards = searcher.search(params)
      if params.include?('response_url')
        @cards
      else
        haml :show_cards 
      end
    end
  end
end