require 'app2engine/rake/tasks'

module App2Engine
  def install(dir)
    unless File.directory?(dir) and
        rakefile = File.join(dir, 'Rakefile') and File.exist?(rakefile) and
        gemfile  = File.join(dir, 'Gemfile')  and File.exist?(gemfile)
      raise "#{dir} is not a rails app"
    end
    
    tasks = App2Engine::Rake::Tasks.new
    
    puts "Appending the App2Engine tasks to the Rakefile"
    tasks.append_to_file(rakefile, "require 'app2engine/rake/tasks'\nApp2Engine::Rake::Tasks.new")
    
    puts "Adding app2engine in the Gemfile (necessary for Rake tasks to run)"
    tasks.append_to_file(gemfile, "gem 'app2engine'")
  end
  module_function :install
end
