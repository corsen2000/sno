require "sno/extractor_base"

module Sno
  def sno_init(input_dir, output_dir, options)
    input_dir = File.expand_path(input_dir)
    assets_root = "#{output_dir}/.sno"

    Dir.mkdir(output_dir) unless Dir.exists? output_dir
    Dir.mkdir(assets_root) unless Dir.exists? assets_root

    copy_if_needed "#{SNO_ROOT}/assets/base/global.css", "#{assets_root}/global.css", options
    options[:css_file] = "global"
    options[:assets_root] = assets_root

    copy_if_needed "#{SNO_ROOT}/assets/lib/jquery-1.7.2.js", "#{assets_root}/jquery.js", options
    copy_if_needed "#{SNO_ROOT}/assets/base/simple_search.js", "#{assets_root}/simple_search.js", options
    copy_if_needed "#{SNO_ROOT}/assets/lib/jquery-ui-1.8.18.custom.min.js", "#{assets_root}/jquery-ui.js", options
    copy_if_needed "#{SNO_ROOT}/assets/lib/jquery-ui-1.8.18.custom.css", "#{assets_root}/jquery-ui.css", options
    copy_if_needed "#{SNO_ROOT}/assets/lib/images", "#{assets_root}/images", options
    copy_if_needed "#{SNO_ROOT}/assets/base/.snoignore", "#{input_dir}/.snoignore", options

    File.open("#{input_dir}/.snoignore").each do |line|
      Extractor.add_ignore("#{input_dir}/#{line.chomp}")
    end

    [Extractor.extractor_for(input_dir).new(input_dir, output_dir, options), assets_root]
  end

  def copy_if_needed(source, dest, options, dir = false)
    if !File.exists?(dest) || options[:force]
      if dir
        FileUtils.copy source, dest
      else
        FileUtils.copy_entry source, dest
      end
    end
  end
end