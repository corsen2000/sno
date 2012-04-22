require 'guard/guard'

module ::Guard
  class Sno < ::Guard::Guard
    def run_all
      compile_sass
      compile_coffee
      compile_sno
    end

    def run_on_change(paths)
      success = true
      paths.each do |path|
        extension = File.extname path
        success = success && compile_sass if extension == ".scss"
        success = success && compile_coffee if extension == ".coffee"
        success = success && compile_sno(extension)        
      end
      Notifier.notify "Sno: An Error Has Occured", :image => :error unless success
    end

    private
    def compile_sass
      puts "Compiling Sass..."
      output = `sass -r ./assets/private/css/bourbon/lib/bourbon.rb --update assets/private/css:assets/public`
      success = $?.exitstatus == 0
      UI.error output unless success
      success
    end

    def compile_coffee
      puts "Compiling CoffeeScript..."
       `coffee -o assets/public/ -c assets/private/`       
       $?.exitstatus == 0
    end

    def compile_sno(trigger_extension = ".scss")
      force = %w(.scss .coffee).include?(trigger_extension) ? "-f" : ""
      puts "Compiling Sno..."
      `ruby -Ilib bin/sno TestRoot SnoOut #{force} -n Developing`
      $?.exitstatus == 0
    end
  end
end

guard :sno do
  watch /^assets\/private\/css.*\.scss/
  watch /^assets\/private.*\.coffee/
  watch /^bin\/.*/
  watch /^lib\/.*/
end
