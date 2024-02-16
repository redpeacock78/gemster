require "yaml"
require "colorize"

def run_initialize
  conf_file_name : String = "gemster.yml"

  puts "#{"[*]".colorize(:light_blue)} writing template to `#{conf_file_name}`"

  if File.exists?("#{conf_file_name}")
    puts "#{"[*]".colorize(:light_blue)} `#{conf_file_name}` file already exists."
    exit(0)
  end

  begin
    data = {tasks: {run: {cmd: "crystal src/main.cr", desc: "Build and run program"}}}
    File.open("#{conf_file_name}", "w") { |f| YAML.dump(data, f) }
    puts "#{"[*]".colorize(:light_blue)} `#{conf_file_name}` created in current working directory"
    exit(0)
  rescue ex
    puts "#{"[E]".colorize(:light_red)} Failed to read configuration file - #{ex.message}"
    exit(1)
  end
end
