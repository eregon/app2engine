module App2Engine
  module Rake
    class Tasks
      SASS = <<SASS
    initializer "sass" do |app|
      require 'sass/plugin/rack'
      template_location = __PROJECT__::Engine.root.join('public/stylesheets/sass').to_s
      css_location = __PROJECT__::Engine.root.join('public/stylesheets').to_s
      Sass::Plugin.add_template_location(template_location, css_location)
    end
SASS

      def extra_tasks
        tasks = %w[sass]
        task :extra => tasks.map { |t| "engine:extra:" << t }
        namespace :extra do
          tasks.each { |t| send(t) }
        end
      end

      def sass
        define_task(:sass, "configure the project to be used with Sass") do
            append_in_class('lib/__project__/engine.rb', SASS)
        end
      end

    end # Tasks
  end # Rake
end # App2Engine
