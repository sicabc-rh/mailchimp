
require 'csv'

def merge_and_filter_members(active_file, expired_file, output_file)
  active = CSV.read(active_file, headers: true)
  expired = CSV.read(expired_file, headers: true)

  #Dir.mkdir("filtered_processed") unless Dir.exist?("filtered_processed")
  # Merge into one file
  CSV.open(output_file, 'w') do |csv|
    csv << active.headers

    active.each { |row| csv << row }
    expired.each { |row| csv << row }
  end

  members = CSV.read(output_file, headers: true)
  keep_columns = ['Company Name', 'Membership Type', 'Status', 'Join Date', 'Business Type', 'City']
  
  # Filter CSV to keep only selected columns
  filtered_file = File.join("processed", "filtered_#{File.basename(output_file)}")
  CSV.open(filtered_file, 'w') do |csv|
    csv << keep_columns

    members.each do |row|
      filtered_row = row.to_h.select { |key, _| keep_columns.include?(key) }
      csv << filtered_row.values
    end
  end

  

end

=begin

active_file = 'activemar4.csv'
expired_file = 'expiredmar4.csv'
output_file = 'membersmar4.csv'

merge_and_filter_members(active_file, expired_file, output_file)
=end