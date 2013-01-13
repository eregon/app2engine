require 'fileutils'

require 'rake'

require 'app2engine/rake/convert_tasks'
require 'app2engine/rake/extra_tasks'

require 'term/ansicolor'
class String
  [:green, :red, :black, :blue, :yellow, :white].each { |method|
    define_method(method) {
      Term::ANSIColor.send(method, self)
    }
  }
end

module App2Engine
  module Rake
    class Tasks
      include ::Rake::DSL

      FILES_PATH = File.expand_path("../../files", __FILE__)

      def initialize
        @dir = File.basename(File.expand_path("."))
        @project = @dir.split(/[^A-Za-z0-9]/).map(&:capitalize).join # Camelize

        namespace :engine do
          convert_tasks
          extra_tasks
        end
        desc "Alias for engine:convert"
        task :engine => "engine:convert"
      end

      def define_task(name, description, &block)
        desc description
        task(name) {
          puts name.to_s.capitalize.blue
          block.call
        }
      end

      # Templates conventions
      def resolve_contents(contents)
        contents.gsub("__PROJECT__", @project).gsub("__DIR__", @dir)
      end

      def resolve_name(name)
        name.gsub("__project__", @dir)
      end

      def status status
        puts "  #{status}"
      end

      def already_done what
        status "already done (#{what})".black # yellow
      end

      def file_contents file
        resolve_contents File.read(File.join(FILES_PATH, file))
      end

      def mkdir dir
        dir = resolve_name(dir)
        if File.directory? dir
          already_done dir
        else
          FileUtils.mkdir_p(dir)
          status "Create #{dir}/".green
        end
      end

      def add_file file
        contents = file_contents(file)
        file = resolve_name(file)
        if File.exist? file
          already_done file
        else
          File.open(file, 'w') { |fh| fh.write(contents) }
          status "Create #{file}".green
        end
      end

      def comment_whole_file file
        file = resolve_name(file)
        lines = File.readlines(file)
        new_lines = lines.map { |line|
          (line =~ /^(\s*|\s*#.+)$/) ? line : '# '+line
        }
        if new_lines == lines
          already_done file
        else
          File.open(file, 'w') { |fh| fh.write(new_lines.join) }
          status "Comment #{file}".green
        end
      end

      def append_to_file file, contents
        file = resolve_name(file)
        if File.read(file).include?(contents)
          already_done file
        else
          File.open(file, 'a') { |fh|
            fh.puts
            fh.puts contents
          }
          status "Append #{file}".green
        end
      end

      def append_in_class(file, what)
        file = resolve_name(file)
        what = resolve_contents(what)
        if File.read(file).include?(what)
          already_done file
        else
          lines = File.readlines(file)
          class_indent = lines.find { |line| line =~ /^\s*class .+$/ }.split(//).index('c')
          class_end = lines.rindex { |line| line =~ /^\s{#{class_indent}}end\s*$/ }
          what = what.split("\n").map { |line| line.chomp + "\n" }
          lines = lines[0...class_end] + ["\n"] + what + lines[class_end..-1]
          File.open(file, 'w') { |fh| fh.write(lines.join) }
          status "Append #{file}".green
        end
      end

      def replace_line(file, line, by)
        line = line.chomp + "\n"
        by = by.chomp + "\n"
        lines = File.readlines(file)
        if lines.include? by
          already_done(file)
        else
          if i = lines.index(line)
            lines[i] = by
            File.open(file, 'w') { |fh| fh.write(lines.join) }
            status "Edit #{file}".green
          else
            status "#{file}: line '#{line}' not found".red
          end
        end
      end
    end # Tasks
  end # Rake
end # App2Engine
