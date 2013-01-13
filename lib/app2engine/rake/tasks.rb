require 'path'
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

      FILES_PATH = Path.relative("../files")

      def initialize
        @dir = Path.pwd.basename
        @project = @dir.path.split(/[^A-Za-z0-9]/).map(&:capitalize).join # Camelize

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
        contents.gsub("__PROJECT__", @project).gsub("__DIR__", @dir.to_s)
      end

      def resolve_name(name)
        Path(name.gsub("__project__", @dir.to_s))
      end

      def status status
        puts "  #{status}"
      end

      def already_done what
        status "already done (#{what})".black # yellow
      end

      def file_contents file
        resolve_contents (FILES_PATH / file).read
      end

      def mkdir dir
        dir = resolve_name(dir)
        if dir.directory?
          already_done dir
        else
          dir.mkpath
          status "Create #{dir}/".green
        end
      end

      def add_file file
        contents = file_contents(file)
        file = resolve_name(file)
        if file.exist?
          already_done file
        else
          file.write(contents)
          status "Create #{file}".green
        end
      end

      def comment_whole_file file
        file = resolve_name(file)
        lines = file.readlines
        new_lines = lines.map { |line|
          (line =~ /^(\s*|\s*#.+)$/) ? line : '# '+line
        }
        if new_lines == lines
          already_done file
        else
          file.write(new_lines.join)
          status "Comment #{file}".green
        end
      end

      def append_to_file file, contents
        file = resolve_name(file)
        if file.read.include?(contents)
          already_done file
        else
          file.open('a') { |fh|
            fh.puts
            fh.puts contents
          }
          status "Append #{file}".green
        end
      end

      def append_in_class(file, what)
        file = resolve_name(file)
        what = resolve_contents(what)
        if file.read.include?(what)
          already_done file
        else
          lines = file.readlines
          class_indent = lines.find { |line| line =~ /^\s*class .+$/ }.split(//).index('c')
          class_end = lines.rindex { |line| line =~ /^\s{#{class_indent}}end\s*$/ }
          what = what.split("\n").map { |line| line.chomp + "\n" }
          lines = lines[0...class_end] + ["\n"] + what + lines[class_end..-1]
          file.write(lines.join)
          status "Append #{file}".green
        end
      end

      def replace_line(file, line, by)
        file = Path(file)
        line = line.chomp + "\n"
        by = by.chomp + "\n"
        lines = file.readlines
        if lines.include? by
          already_done(file)
        else
          if i = lines.index(line)
            lines[i] = by
            file.write(lines.join)
            status "Edit #{file}".green
          else
            status "#{file}: line '#{line}' not found".red
          end
        end
      end
    end # Tasks
  end # Rake
end # App2Engine
