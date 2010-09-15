module App2Engine
  module Rake
    class Tasks
      def convert_tasks
        tasks = %w[gemspec routes hierarchy initializers generators]
        task :convert => tasks.map { |t| "engine:convert:" << t } do
          puts
          puts "Now your app should be ready to be used as an Engine".blue
          puts "You have to add this to you main app's Gemfile:".red
          puts "gem '#{@dir}', :path => 'path/to/#{@dir}'"
          puts "You may want to remove the dependency to app2engine in the Engine's Gemfile".blue
        end
        namespace :convert do
          tasks.each { |t| send(t) }
        end
      end

      def gemspec
        define_task(:gemspec, "add Jeweler to the Rakefile to allow to build a gem which can be referenced from the main app") do
          add_file('__project__.gemspec')
        end
      end

      def routes
        define_task(:routes, "Change routes to not have a reference to the application, but to the main app") do
          replace_line('config/routes.rb', "#{@project}::Application.routes.draw do", "Rails.application.routes.draw do")
        end
      end

      def hierarchy
        define_task(:hierarchy, "add the basic hierarchy for the Engine") do
          add_file('lib/__project__.rb')
          mkdir("lib/#{@dir}")
          add_file('lib/__project__/engine.rb')

          mkdir("app/controllers/__project__")
          mkdir("app/models/__project__")
          mkdir("app/views/__project__")
        end
      end

      def initializers
        define_task(:initializers, "remove initializers as they would conflict and create NameError") do
          Dir['config/initializers/{secret_token,session_store}.rb'].each { |file| comment_whole_file(file) }
        end
      end

      def generators
        define_task(:generators, "add the basic code for generators (needed for migrations)") do
          mkdir('lib/generators/__project__/migrations/templates')
          add_file('lib/generators/__project__/migrations/migrations_generator.rb')
        end
      end
    end # Tasks
  end # Rake
end # App2Engine
