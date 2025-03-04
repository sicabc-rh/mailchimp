require 'csv'

def filter_users(user_file)
  users = CSV.read(user_file, headers: true)

  keep_columns = ['FirstName', 'LastName', 'CompanyName', 'Email', 'Roles']

  CSV.open("filtered_#{user_file}", 'w') do |csv|
    
    # Write the headers
    csv << keep_columns

    # Write filtered rows (keeping only selected columns)
    users.each do |row|
      filtered_row = row.to_h.select { |key, _| keep_columns.include?(key) }
      csv << filtered_row.values
    end
  end
end

=begin
user_file = 'usersmar4.csv'

filter_users(user_file)
=end
