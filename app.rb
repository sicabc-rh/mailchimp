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
  erb :index, locals: { error: nil }  # Load the HTML form
end

post '/upload' do
  # Check if all required files are uploaded
  if !params[:active] || !params[:expired] || !params[:users]
    return erb :index, locals: { error: "Please upload all three files before processing." }
  end

  # Debugging: Print out the filenames of uploaded files
  puts "Active file: #{params[:active][:filename]}"
  puts "Expired file: #{params[:expired][:filename]}"
  puts "Users file: #{params[:users][:filename]}"

  # Save uploaded files
  ['active', 'expired', 'users'].each do |type|
    if params[type] && params[type][:tempfile]
      filepath = File.join(settings.uploads_folder, params[type][:filename])
      File.open(filepath, 'wb') { |f| f.write(params[type][:tempfile].read) }
    end
  end

  # Define file paths for the uploaded files
  active_file = File.join(settings.uploads_folder, params[:active][:filename])
  expired_file = File.join(settings.uploads_folder, params[:expired][:filename])
  user_file = File.join(settings.uploads_folder, params[:users][:filename])

  # Define output file paths
  members_output = File.join(settings.processed_folder, 'members.csv')
  final_output = File.join(settings.processed_folder, 'final_output.csv')

  # Run processing steps
  merge_and_filter_members(active_file, expired_file, members_output)
  filter_users(user_file)
  merge_users_and_members("processed/filtered_#{File.basename(user_file)}", "processed/filtered_#{File.basename(members_output)}", final_output)

  # Provide a download link
  erb :download, locals: { file: final_output }
end

# Add this route below all other routes in `app.rb`
get '/processed/:filename' do
  file_path = File.join(settings.processed_folder, params[:filename])

  if File.exist?(file_path)
    send_file file_path, filename: params[:filename], type: 'application/csv'
  else
    halt 404, "File not found"
  end
end
