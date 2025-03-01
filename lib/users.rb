require 'csv'

users = CSV.read(user_file, headers: true)

keep_columns = ['FirstName', 'LastName', 'CompanyName', 'Email', 'Roles']

CSV.open('filtered_users_#{date}', 'w') do |csv|
    
  # Write the headers
  csv << keep_columns

  # Write filtered rows (keeping only selected columns)
  users.each do |row|
    filtered_row = row.to_h.select { |key, _| keep_columns.include?(key) }
    csv << filtered_row.values
  end
end
