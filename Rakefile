require 'rake/minify'

def sass2css(from, to)
  system "sass #{from} #{to}"
end

def cp_filter(from, to)
  File.open(to, "w") do |out|
    File.open(from) do |file|
      file.each { |line|
        out << yield(line)
      }
    end
  end
end

namespace :extension do

  task :clean do
    FileUtils.rm_rf('extension/js')
    FileUtils.rm_rf('extension/css')
    FileUtils.rm_f('extension/popup.html')
  end

  task :sass do
    FileList['views/sass/*'].each { |sass|
      sass2css sass, "extension/css/#{sass.pathmap("%n")}.css"
    }
  end

  Rake::Minify.new(:source) do
    fl = FileList['views/coffee/*.coffee']
    fl.exclude("**/test-*")
    fl.each { |file|
      add("extension/js/#{file.pathmap("%n")}.js", file, :minify => false)
    }
  end

  task :dirs do
    FileUtils.mkdir_p "extension/js"
    FileUtils.mkdir_p "extension/css"
  end

  task :content do
    FileUtils.cp_r "public/js", "extension"
    FileUtils.cp_r "public/css", "extension"
    FileUtils.cp "public/popup.html", "extension/popup.html"
  end

  task :package => [:dirs, :sass, :source, :content] do
    puts "extension packaged OK."
  end

end



