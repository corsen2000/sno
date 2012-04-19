require "sno/extractor_base"

module Sno

  class Sno
    def initialize(input_dir, options)
      @input_dir = File.expand_path(input_dir).chomp("/")
      @options = default_options.merge options
      @options[:output_dir] = @options[:output_dir].chomp("/")
      @input_assets_path = "#{SNO_ROOT}/assets/"
      @output_assets_path = "#{@options[:output_dir]}/.sno/assets"
    end

    def default_options
      {
        output_dir: "#{@input_dir}/SnoOut",
        notebook_name: "Sno",
        force: false
      }
    end

    def generate_notebook
      pre_generation
      generation
      post_generation
    end

    def pre_generation
      prepare_output_directory
      prepare_output_assets
      set_extractor_ignores
    end

    def generation
      extractor_options = @options.merge({
        assets_path: @output_assets_path, 
        templates_path: "#{@input_assets_path}/private/templates"
      })
      extractor_klass = Extractor.extractor_for(@input_dir)
      root_extractor = extractor_klass.new(@input_dir, @options[:output_dir], extractor_options)
      root_extractor.save      
    end

    def post_generation
      prepare_simple_search
    end

    def prepare_output_directory      
      Dir.mkdir(@options[:output_dir]) unless Dir.exists? @options[:output_dir]
      Dir.mkdir("#{@options[:output_dir]}/.sno") unless Dir.exists? "#{@options[:output_dir]}/.sno"
    end

    def prepare_output_assets
      copy_directory "#{@input_assets_path}/public", "#{@output_assets_path}"
    end

    def copy_directory(src, dest)
      if !Dir.exists?(dest) || @options[:force]
        FileUtils.copy_entry src, dest
      end
    end

    def set_extractor_ignores
      if File.exists? "#{@input_dir}/.snoignore"
        File.open("#{@input_dir}/.snoignore").each do |line|
          Extractor.add_ignore("#{@input_dir}/#{line.chomp}")
        end
      end
    end

    def prepare_simple_search
      File.open("#{@output_assets_path}/search_index.js", "w+") do |f|
        f.puts "var searchIndex = JSON.parse('#{JSON(Page.pages)}');"
      end
    end
  end

end