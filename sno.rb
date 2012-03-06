require 'optparse'
require_relative "extractors.rb"

options = {
    :project_name => nil
}

OptionParser.new do |opts|
	opts.banner = "Usage: sno.rb input_dir [output_dir] [options]"

	opts.on("-n", "--project-name [NAME]", String, "Specify a name to persist throughout the pages") do |n|
    	options[:project_name] = n
  	end

  	opts.on("-h", "--help", "Show this message") do
    	puts opts
    exit
  end
end.parse!

input_dir = ARGV[0] or raise "You must specify a input directory!"
output_dir = ARGV[1] || "#{input_dir}/SnoOut"

Dir.mkdir(output_dir) unless Dir.exists? output_dir

root = IndexPage.new input_dir, output_dir, options[:project_name]
root.save