require "haml"
require "cgi"
require "fileutils"
require "active_support/inflector"
require "pathname"
require "base64"

def directories(extractors)
	extractors.reject { |item| item.class != IndexPage }
	
end

def files(extractors)
	extractors.reject { |item| item.class == IndexPage }
end

class Extractor	
	attr_accessor :file_path
	attr_accessor :output_dir

	def initialize(file_path, output_dir)
		@file_path = file_path
		@output_dir = output_dir
	end

	def save
		FileUtils.copy file_path, output_path
	end

	private
	def output_path
		"#{output_dir}/#{output_name}"
	end

	def output_name
		File.basename(file_path, ".*") + output_extension
	end

	def output_extension
		File.extname file_path
	end
end

class Linker < Extractor
	def link
		"#{File.basename output_dir}/#{output_name}"
	end
end

class Page < Linker
	include ActiveSupport::Inflector
	attr_accessor :content
	attr_accessor :name
	attr_accessor :css_path
	attr_accessor :options

	def initialize(file_path, output_dir, options = {})
		super file_path, output_dir
		@name = File.basename file_path, ".*"
		@options = options
		@css_path = Pathname.new(options[:css_file]).relative_path_from Pathname.new output_dir if options[:css_file]
	end

	def title
		options[:project_name] ||= titleize(name)
	end

	def header
		name
	end

	def content
		@content ||= extract_content
	end

	def output_extension
		".html"
	end

	def to_html
		page_engine = Haml::Engine.new(File.read("layout.haml"))
		page_engine.render(self)
	end

	def save
		File.open(output_path, "w+") do |file|
			file.puts self.to_html
		end
	end
end

class IndexPage < Page
	attr_reader :children

	def extract_content()
		@children = []
		Dir.glob("#{file_path}/*").each do |file|
			unless IGNORE.member?(File.basename file)								
				extractor = create_extractor(file)
				children << extractor unless extractor.nil?
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

	private
	def create_extractor(file)
		if File.directory? file				
			IndexPage.new(file, "#{output_dir}/#{File.basename file_path}", options)
		else
			extractor = find_extractor File.basename file
			extractor.new(file, "#{output_dir}/#{File.basename file_path}", options) if extractor
		end
	end

	def find_extractor(filename)
		extractor = EXTRACTORS.detect do |regex, extractor|
			 regex.match(filename)
		end
		extractor.last unless extractor.nil?
	end
end

class TextPage < Page
	def extract_content
		CGI::escapeHTML File.read(file_path)
	end
end

class HtmlPage < Page
	def extract_content
		File.read file_path
	end
end

class HamlPage < Page
	def extract_content
		Haml::Engine.new(File.read(file_path)).render
	end
end

class ImagePage < Page
	def extract_content
		base64 = Base64.encode64(File.read(file_path))		
		"<img src=\"data:image/#{File.extname file_path};base64,#{base64}\" />"
	end
end

EXTRACTORS = {
	/.*\.txt/ => TextPage,
	/.*\.html/ => HtmlPage,
	/.*\.haml/ => HamlPage,
	/.*\.jpg/ => ImagePage
}

IGNORE = Set.new ["SnoOut"]