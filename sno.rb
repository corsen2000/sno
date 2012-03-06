require "haml"
require_relative "extractors.rb"

input_dir = "/Users/Corsen/Documents/sno/TestRoot"
output_dir = "/Users/Corsen/Documents/sno/SnoOut"
project_name = "Bryans Bag"

Dir.mkdir(output_dir) unless Dir.exists? output_dir

root = IndexPage.new input_dir, output_dir, project_name
root.save