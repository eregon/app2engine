require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "app2engine"
    gem.summary = %Q{Convert a Rails 3 app to an Engine}
    gem.description = %Q{Ease the convertion of a Rails 3 app in an Engine}
    gem.email = "eregontp@gmail.com"
    gem.homepage = "http://github.com/eregon/app2engine"
    gem.authors = ["eregon"]
    gem.add_dependency("term-ansicolor")
    gem.files = Dir['bin/*'] + Dir['lib/**/*']
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "app2engine #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
