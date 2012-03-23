require "sno/extractor_base"

module Sno
	def sno_init(input_dir, output_dir, options)
		input_dir = File.expand_path(input_dir)

		Dir.mkdir(output_dir) unless Dir.exists? output_dir

		css_file_copy = "#{output_dir}/global.css"
		FileUtils.copy "#{SNO_ROOT}/assets/base/global.css", css_file_copy
		options[:css_file] = css_file_copy

		jquery_file_copy = "#{output_dir}/jquery.js"
		FileUtils.copy "#{SNO_ROOT}/assets/lib/jquery-1.7.2.js", jquery_file_copy

		FileUtils.copy "#{SNO_ROOT}/assets/base/simple_search.js", "#{output_dir}/simple_search.js"

		FileUtils.copy "#{SNO_ROOT}/assets/lib/jquery-ui-1.8.18.custom.min.js", "#{output_dir}/jquery-ui.js"

		FileUtils.copy "#{SNO_ROOT}/assets/lib/jquery-ui-1.8.18.custom.css", "#{output_dir}/jquery-ui.css"

		FileUtils.copy_entry "#{SNO_ROOT}/assets/lib/images", "#{output_dir}/images"

		unless File.exists? "#{input_dir}/.snoignore"
			FileUtils.copy "#{SNO_ROOT}/assets/base/.snoignore", "#{input_dir}/.snoignore"
		end
		File.open("#{input_dir}/.snoignore").each do |line|
			Extractor.add_ignore("#{input_dir}/#{line.chomp}")
		end

		Extractor.extractor_for(input_dir).new input_dir, output_dir, options
	end
end