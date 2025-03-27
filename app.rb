require 'sinatra'
require 'csv'
require 'time'
require_relative 'lib/mailchimp'
require_relative 'lib/members'
require_relative 'lib/users'
require_relative 'lib/removed'

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
    return erb :index, locals: { error: "Please upload all required files before processing." }
  end

  # Debugging: Print out the filenames of uploaded files
  puts "Active file: #{params[:active][:filename]}"
  puts "Expired file: #{params[:expired][:filename]}"
  puts "Users file: #{params[:users][:filename]}"
  #puts "Old file: #{params[:old_file_data][:filename]}"

  # Check if old file is provided
  old_file = params[:old_file_data] ? File.join(settings.uploads_folder, params[:old_file_data][:filename]) : nil

  # Save uploaded files
  ['active', 'expired', 'users', 'old_file_data'].each do |type|
    if params[type] && params[type][:tempfile]
      filepath = File.join(settings.uploads_folder, params[type][:filename])
      File.open(filepath, 'wb') { |f| f.write(params[type][:tempfile].read) }
    end
  end

  # Define file paths for the uploaded files
  active_file = File.join(settings.uploads_folder, params[:active][:filename])
  expired_file = File.join(settings.uploads_folder, params[:expired][:filename])
  user_file = File.join(settings.uploads_folder, params[:users][:filename])
  #old_file = File.join(setting.uploads_folder, params[:old_file_data][:filename])

  # Define output file paths
  members_output = File.join(settings.processed_folder, 'members.csv')
  date_string = Time.now.strftime("%b%d_%Y")
  final_output = File.join(settings.processed_folder, "mailchimp_contacts_#{date_string}.csv")
  updated_file = File.join(settings.processed_folder, "updated_#{date_string}.csv")

  # Run processing steps
  merge_and_filter_members(active_file, expired_file, members_output)
  filter_users(user_file)
  merge_users_and_members("processed/filtered_#{File.basename(user_file)}", "processed/filtered_#{File.basename(members_output)}", final_output)
  #add_lines_to_final_output(final_output, old_file, updated_file)

  # If old file provided, process it
  if old_file
    add_lines_to_final_output(final_output, old_file, updated_file)
  else
    # If no old file provided, just copy final output to updated_file
    FileUtils.cp(final_output, updated_file)
  end
  # Provide a download link
  erb :download, locals: { file: updated_file }
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
