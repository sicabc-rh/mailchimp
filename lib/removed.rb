# lib/removed.rb
require 'csv'

def add_lines_to_final_output(final_output, old_file, updated_file)
  # Open the final output file and the old file
  final_file_data = CSV.read(final_output, headers: true)
  old_file_data = CSV.read(old_file, headers: true)

  # Get the email addresses from the final output and old file
  final_emails = final_file_data['Email Address']  # Assuming 'Email' is the column header for email addresses
  old_data_cleaned = old_file_data.reject { |row| row['Tags'] == 'REMOVE' }
  added_rows = []

  # Iterate through the rows in the old file
  old_data_cleaned.each do |row|
    if row['Tags'] == 'REMOVE'
      
    end
    email = row['Email Address']  # Assuming 'Email' is the column header for email addresses
    
    # If the email from the old file is not found in the final output, add the row
    unless final_emails.include?(email)
      row['Tags'] = 'REMOVE'  # Set the "Tags" column to "remove"
      added_rows << row  # Add this row to the list of rows to be appended
    end
  end

  added_rows.each do |row|
    final_file_data << row
  end

  # Write the modified data to the updated file
  CSV.open(updated_file, 'wb') do |csv|
    csv << final_file_data.headers  # Write headers
    final_file_data.each do |row|
      csv << row
    end
  end
end
