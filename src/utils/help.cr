require "./*"
require "yaml"
require "colorize"

def show_help
  authors : String = "redpeacock78"
  name : String = File.basename(Process.executable_path.to_s)

  puts "#{name.upcase.colorize(:light_blue)} - #{version}"
  puts "Created by #{authors}"
  puts "Simple task runner with file watch & hot reload functions"
  puts ""
  puts "Usage:"
  puts "    #{name.colorize(:light_blue)} #{"<task name>".colorize(:light_yellow)}"
  puts "    #{name.colorize(:light_blue)} [options]"
  puts ""
  puts "Options:"
  puts "    -h, --help       Show this screen."
  puts "    -v, --version    Show version."
  puts "    -i, --init       Create config file in current working dir."
  exit(0)
end
