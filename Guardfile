require 'guard/guard'

module ::Guard
  class Sno < ::Guard::Guard
    def run_all
      compile_sass
      compile_coffee
      compile_sno
    end

    def run_on_change(paths)
      paths.each do |path|
        extension = File.extname path
        compile_sass if extension == ".scss"
        compile_coffee if extension == ".coffee"
        compile_sno(extension)        
      end
    end

    private
    def compile_sass
      puts "Compiling Sass..."
      `sass -r ./assets/private/css/bourbon/lib/bourbon.rb --update assets/private/css:assets/public`
    end

    def compile_coffee
      puts "Compiling CoffeeScript..."
       `coffee -o assets/public/ -c assets/private/`
    end

    def compile_sno(trigger_extension = ".scss")
      force = %w(.scss .coffee).include?(trigger_extension) ? "-f" : ""
      puts "Compiling Sno..."
      `ruby -Ilib bin/sno TestRoot SnoOut #{force} -n Developing`
    end
  end
end

guard :sno do
  watch /^assets\/private\/css.*\.scss/
  watch /^assets\/private.*\.coffee/
  watch /^bin\/.*/
  watch /^lib\/.*/
end
