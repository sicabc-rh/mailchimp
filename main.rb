

require_relative 'lib/mailchimp'
require_relative 'lib/members'
require_relative 'lib/users'

# Define file names
active_file = 'activemar4.csv'
expired_file = 'expiredmar4.csv'
members_output = 'membersmar4.csv'

user_file = 'usersmar4.csv'
final_output = 'final_merged_file.csv'

# Run the steps
merge_and_filter_members(active_file, expired_file, members_output)
filter_users(user_file)
merge_users_and_members("filtered_#{user_file}", "filtered_#{members_output}", final_output)