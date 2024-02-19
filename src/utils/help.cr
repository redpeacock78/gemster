require "./*"
require "yaml"
require "colorize"

def show_help
  name : String = File.basename(Process.executable_path.to_s)
  authors : String = {{ `awk 'NR==11{print $2}' < shard.yml`.chomp.stringify }}
  description : String = {{ `awk 'NR==14{print}' < shard.yml | cut -d' ' -f 3-`.chomp.stringify }}

  puts "#{name.upcase.colorize(:light_blue)} - #{version}"
  puts "Created by #{authors}"
  puts "#{description}"
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
