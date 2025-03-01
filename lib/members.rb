require 'csv'

# Method to merge and filter CSV files
def merge_and_filter_csv(active_file, expired_file, output_file, keep_columns)
  # Read the active and expired CSV files
  active = CSV.read(active_file, headers: true)
  expired = CSV.read(expired_file, headers: true)

  # Merge active & expired into one file
  CSV.open(output_file, 'w') do |csv|
    # Write headers from the first file (active)
    csv << active.headers

    # Write the rows from both active and expired
    active.each { |row| csv << row }
    expired.each { |row| csv << row }
  end

  # Read merged CSV file for filtering columns
  members = CSV.read(output_file, headers: true)

  # Filter the CSV by keeping only the selected columns
  CSV.open("filtered_#{output_file}", 'w') do |csv|
    # Write the headers
    csv << keep_columns

    # Write filtered rows (keeping only selected columns)
    members.each do |row|
      filtered_row = row.to_h.select { |key, _| keep_columns.include?(key) }
      csv << filtered_row.values
    end
  end

  puts "Merged and filtered CSV saved as 'filtered_#{output_file}'."
end

# Example usage:
active_file = 'active_feb28.csv'
expired_file = 'expired_feb28.csv'
output_file = 'members_feb28.csv'
keep_columns = ['Company Name', 'Membership Type', 'Status', 'Join Date', 'Business Type', 'City']

# Call the method
merge_and_filter_csv(active_file, expired_file, output_file, keep_columns)

