require 'csv'

def merge_users_and_members(user_file, member_file, output_file)
  # Read the filtered members file into a has with Company Name as the key
  members = {}
  CSV.foreach(member_file, headers: true) do |row|
    members[row['Company Name']] = row.to_h
  end

  # Define headers for output file
  headers = ['Email Address', 'First Name', 'Last Name', 'Company Name', 'Join Date', 'City', 'Membership Type', 'Business Type', 'Membership Status', 'Tags']

  CSV.open(output_file, 'w', write_headers: true, headers: headers) do |csv|

    CSV.foreach(user_file, headers: true) do |row|
      company_name = row['CompanyName']

      # If the company exists in the members file, merge data
      if members.key?(company_name)
        merged_row = [
          row['Email'],
          row['FirstName'],
          row['LastName'],
          company_name,
          members[company_name]['Join Date'],
          members[company_name]['City'],
          members[company_name]['Membership Type'],
          members[company_name]['Business Type'],
          members[company_name]['Status'],
          row['Roles']
        ]
        csv << merged_row
      end
    end
  end

end

=begin

user_file = 'filtered_usersmar4.csv'
member_file = 'filtered_membersmar4.csv'
output_file = 'final_test.csv'

merge_users_and_members(user_file, member_file, output_file)
=end