require 'sinatra'
require 'csv'
require_relative 'lib/mailchimp'
require_relative 'lib/members'
require_relative 'lib/users'

set :public_folder, 'public' # For static files (HTML, CSS, JS)
set :uploads_folder, 'uploads'
set :processed_folder, 'processed'

# Ensure directories exist
Dir.mkdir(settings.uploads_folder) unless Dir.exist?(settings.uploads_folder)
Dir.mkdir(settings.processed_folder) unless Dir.exist?(settings.processed_folder)

get '/' do
  erb :index  # Load the HTML form
end

post '/upload' do
  # Save uploaded files
  ['active', 'expired', 'users'].each do |type|
    if params[type] && params[type][:tempfile]
      filepath = File.join(settings.uploads_folder, params[type][:filename])
      File.open(filepath, 'wb') { |f| f.write(params[type][:tempfile].read) }
    end
  end

  # Define file paths
  active_file = Dir.glob("#{settings.uploads_folder}/*active*.csv").first
  expired_file = Dir.glob("#{settings.uploads_folder}/*expired*.csv").first
  user_file = Dir.glob("#{settings.uploads_folder}/*users*.csv").first
  members_output = "#{settings.processed_folder}/members.csv"
  final_output = "#{settings.processed_folder}/final_output.csv"

  # Run processing steps
  merge_and_filter_members(active_file, expired_file, members_output)
  filter_users(user_file)
  merge_users_and_members("filtered_#{user_file}", "filtered_#{members_output}", final_output)

  # Provide a download link
  erb :download, locals: { file: final_output }
end
