require 'bundler'
Bundler.require

require 'sinatra/activerecord'
require './lib/spacecat'
require './environments'

class SpacecatApp < Sinatra::Application

  configure do
    set :root, File.dirname(__FILE__)
    set :public_folder, 'public/app'
  end

  configure :development do
   set :database, 'sqlite3:///dev.db'
   set :show_exceptions, true
  end
  
  configure :production do
   db = URI.parse(ENV['DATABASE_URL'] || 'postgres:///localhost/mydb')
  
   ActiveRecord::Base.establish_connection(
     :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
     :host     => db.host,
     :username => db.user,
     :password => db.password,
     :database => db.path[1..-1],
     :encoding => 'utf8'
   )
  end

  get '/' do
    File.read(File.join('public', 'index.html'))
  end

  get '/spacecats' do
    @spacecats = Spacecat.all

    @spacecats.to_json
  end

  get '/spacecats/:id' do
    @spacecat = Spacecat.find(params[:id])

    @spacecat.to_json
  end

  post '/spacecats' do
    @spacecat = Spacecat.create!(params)

    redirect '/'
  end

end