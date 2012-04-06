require "sno/extractor_base"

module Sno

  class Sno
    def initialize(input_dir, options)
      @input_dir = File.expand_path input_dir
      @options = default_options.merge options
      @input_assets_path = "#{SNO_ROOT}/assets/"
      @output_assets_path = "#{@options[:output_dir]}/.sno"
    end

    def default_options
      {
        output_dir: "#{@input_dir}/SnoOut/",
        notebook_name: "Sno",
        force: false
      }
    end

    def generate_notebook
      prepare_output_directory
      prepare_output_assets
      set_extractor_ignores
      extractor_klass = Extractor.extractor_for(@input_dir)
      root_extractor = extractor_klass.new(@input_dir, @options[:output_dir], @options.merge({assets_path: @output_assets_path, input_assets_path: @input_assets_path}))
      root_extractor.save
      prepare_simple_search
    end

    def prepare_output_directory
      Dir.mkdir(@options[:output_dir]) unless Dir.exists? @options[:output_dir]
      Dir.mkdir(@output_assets_path) unless Dir.exists? @output_assets_path
    end

    def prepare_output_assets
      FileUtils.copy_entry "#{@input_assets_path}/lib", "#{@output_assets_path}/lib"
      FileUtils.copy_entry "#{@input_assets_path}/base", "#{@output_assets_path}/base"
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