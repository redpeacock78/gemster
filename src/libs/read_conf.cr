require "yaml"
require "colorize"
require "../utils/*"

def read_conf
  pwd : String = Dir.current
  conf_file_name : String = "gemster"
  conf_file_path : String = ""
  conf_file_path = "#{pwd}/#{conf_file_name}.yml" if File.exists?("#{pwd}/#{conf_file_name}.yml")
  conf_file_path = "#{pwd}/#{conf_file_name}.yaml" if File.exists?("#{pwd}/#{conf_file_name}.yaml")
  if conf_file_path.size == 0
    puts "#{"[*]".colorize(:light_blue)} v#{version}"
    puts "#{"[E]".colorize(:light_red)} Cannot find `#{conf_file_name}.yml` or `#{conf_file_name}.yaml` in the current directory!"
    puts "#{"[*]".colorize(:light_blue)} You can create a config to add scripts to with `#{File.basename(Process.executable_path.to_s).colorize(:light_blue)} #{"--init".colorize(:light_yellow)}`."
    exit(1)
  end
  begin
    YAML.parse(File.read(conf_file_path))
  rescue ex
    puts "#{"[*]".colorize(:light_blue)} v#{version}"
    puts "#{"[E]".colorize(:light_red)} Failed to read configuration file - #{ex.message}"
    exit(1)
  end
end
