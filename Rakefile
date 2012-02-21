require 'rake/minify'

ENV['PATH'] = "/usr/local/bin:#{ENV['PATH']}"
ENV['NODE_PATH'] = "/usr/local/lib/node_modules:/usr/local/lib/node:"

def less2css(from, to)
  system "lessc #{from} #{to}"
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

  task :less do
    FileList['views/css/*.less'].each { |less|
      less2css less, "extension/css/#{less.pathmap("%n")}.css"
    }
  end

  Rake::Minify.new(:source) do
    fl = FileList['views/js/*.coffee']
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

  task :package => [:dirs, :less, :source, :content] do
    puts "extension packaged OK."
  end

end


task :test do
  system 'sh -c "nodeunit test/*"'
end


