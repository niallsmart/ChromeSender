require 'rake/minify'

def sass2css(from, to)
  system "sass #{from} #{to}"
end


def filter_src(from, to)

  File.open(to, "w") do |out|

    File.open(from) do |file|
      file.each { |line|
        #line = line.gsub(/( (href|src)=\")\//, '\1chrome-extension://__MSG_@@extension_id__/')
        out << line
      }
    end

  end

end

namespace :extension do

  task :clean do
    FileUtils.rm_rf('extension/js')
    FileUtils.rm_rf('extension/css')
    FileUtils.rm_rf('extension/*.html')
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
    FileUtils.cp "public/index.html", "extension/popup.html"
    #filter_src "public/index.html", "extension/popup.html"
  end

  task :package => [:dirs, :sass, :source, :content]

end



