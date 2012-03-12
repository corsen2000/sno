require "haml"
require "cgi"
require "fileutils"
require "active_support/inflector"
require "pathname"
require "base64"

class Extractor
	@@file_matchers = []
	@@directory_matchers = []
	@@ignore_patterns = []
	attr_accessor :file_path
	attr_accessor :output_dir
	attr_accessor :options

	def initialize(file_path, output_dir, options = {})
		@file_path = file_path
		@output_dir = output_dir
		@options = options
	end

	def directory?
		false
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

	def self.add_matcher(matcher, directory = false)
		if directory
			@@directory_matchers << matcher
		else
			@@file_matchers << matcher
		end		
	end

	def self.add_ignore(regex)
		@@ignore_patterns << regex
	end

	def self.extractor_for(file_path)
		unless @@ignore_patterns.any? { |pattern| !file_path.match(pattern).nil? }
			matchers = File.directory?(file_path) ? @@directory_matchers : @@file_matchers 
			filename = File.basename file_path
			matcher = matchers.detect do |matcher|
				matcher[:expressions].any? do |expression|
					expression.match(filename)
				end
			end
			matcher[:class] unless matcher.nil?
		end
	end
end

class Linker < Extractor
	def link_type
		:raw
	end
	def link
		"#{File.basename output_dir}/#{output_name}"
	end
end
Extractor.add_matcher({:class => Linker, :expressions => [/.*\.pdf/]})

class Page < Linker
	include ActiveSupport::Inflector
	attr_accessor :content
	attr_accessor :name
	attr_accessor :css_path	
	attr_accessor :root_href

	def initialize(file_path, output_dir, options = {})
		super file_path, output_dir, options
		@name = File.basename file_path, ".*"		
		@css_path = Pathname.new(options[:css_file]).relative_path_from Pathname.new output_dir if options[:css_file]
		options[:root_path] ||= output_path
		@root_href = Pathname.new(options[:root_path]).relative_path_from Pathname.new output_dir 
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
		page_engine = Haml::Engine.new(File.read("#{TEMPLATE_ROOT}/layout.haml"))
		page_engine.render(self)
	end

	def link_type
		:internal
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
			extractor = create_extractor(file)
			if extractor
				children << extractor unless extractor.nil?
			end
		end
		index_engine = Haml::Engine.new(File.read("#{TEMPLATE_ROOT}/index.haml"))
		index_engine.render(self)
	end

	def directory?
		true		
	end

	def directories
		children.reject { |item| !item.directory? }	
	end

	def files
		children.reject { |item| item.directory? }
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
		extractor = Extractor.extractor_for(file)
		extractor.new(file, "#{output_dir}/#{File.basename file_path}", options) if extractor
	end
end
Extractor.add_matcher({:class => IndexPage, :expressions => [/.*/]}, true)

class TextPage < Page
	def extract_content
		CGI::escapeHTML File.read(file_path)
	end
end
Extractor.add_matcher({:class => TextPage, :expressions => [/.*\.txt/]})

class HtmlPage < Page
	def extract_content
		File.read file_path
	end
end
Extractor.add_matcher({:class => HtmlPage, :expressions => [/.*\.html/]})

class HamlPage < Page
	def extract_content
		Haml::Engine.new(File.read(file_path)).render
	end
end
Extractor.add_matcher({:class => HamlPage, :expressions => [/.*\.haml/]})

class ImagePage < Page
	def extract_content
		base64 = Base64.encode64(File.read(file_path))		
		"<img src=\"data:image/#{File.extname file_path};base64,#{base64}\" />"
	end
end
Extractor.add_matcher({:class => ImagePage, :expressions => [/.*\.jpg/]})