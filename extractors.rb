require "haml"
require "cgi"

class Link
	attr_accessor :text
	attr_accessor :href	
	def initialize(text, href)
		@href = href
		@text = text
	end
end

class Page
	attr_accessor :title
	attr_accessor :header
	attr_accessor :content
	attr_accessor :output_dir
	attr_accessor :file_path
	attr_accessor :name

	def initialize(file_path, output_dir, title = nil)
		@file_path = file_path
		@output_dir = output_dir
		@title = title
		@name = File.basename file_path, ".*"
	end

	def title
		@title ||= extract_title(@file_path)
	end

	def header
		@header ||= extract_header(@file_path)
	end

	def content
		@content ||= extract_content(@file_path)
	end
	def extract_title(file_path)
		name
	end
	def extract_header(file_path)
		name
	end
	def to_html
		page_engine = Haml::Engine.new(File.read("layout.haml"))
		page_engine.render(self)
	end
	def save
		File.open("#{output_dir}/#{name}.html", "w+") do |file|
			file.puts self.to_html
		end
	end
end

class IndexPage < Page
	attr_reader :children
	attr_reader :links
	def extract_content(file_path)
		my_name = File.basename file_path
		@links = []
		@children = []
		Dir.glob("#{file_path}/*").each do |file|
			name = File.basename file, ".*"
			links << Link.new(name, "#{output_dir}/#{my_name}/#{name}.html")

			if File.directory? file				
				children << IndexPage.new(file, "#{output_dir}/#{my_name}", title)
			else
				extractor = EXTRACTORS[File.extname(file)]
				children << extractor.new(file, "#{output_dir}/#{my_name}", title)
			end
		end

		index_engine = Haml::Engine.new(File.read("index.haml"))
		index_engine.render(self)
	end
	def save
		super
		children.each do |page|
			Dir.mkdir(page.output_dir) unless Dir.exists? page.output_dir
			page.save
		end
	end
end

class TextPage < Page
	def extract_content(file_path)
		CGI::escapeHTML File.read(file_path)
	end
end

class HtmlPage < Page
	def extract_content(file_path)
		File.read file_path
	end
end

EXTRACTORS = {
	".txt" => TextPage,
	".html" => HtmlPage
}