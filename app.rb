require 'logger'
require 'sinatra'
require 'sinatra/json'

require_relative './lib/wopr'

require 'sinatra/reloader' if WOPR.development?

WOPR.ensure_database_connection!

get '/' do
  slim :index, locals: { bundle: WOPR.javascript_bundle }
end

get '/api' do
  WOPR::API.retrieve_root self
end

post '/api/actions' do
  WOPR::API.create_action self
end