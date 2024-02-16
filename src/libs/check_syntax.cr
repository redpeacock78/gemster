require "colorize"

def check_syntax(data)
  if data.[:yml]["tasks"]? == nil
    puts "error!"
    exit(1)
  elsif data.to_h[:yml]["tasks"] != nil
    begin
      task = data.to_h[:task]
      if data.[:yml]["tasks"][task]? == nil
        puts "#{"[E]".colorize(:light_red)} Task name '#{task}'' is not set."
        exit(1)
      end
      if data.[:yml]["tasks"][task]["cmd"]? == nil
        if data.[:yml]["tasks"][task]["deps"]? == nil
          puts "#{"[E]".colorize(:light_red)} Task set in deps is not set."
          exit(1)
        end
        if data.[:yml]["tasks"][data.[:yml]["tasks"][task]["deps"]?]["cmd"]? == nil
          puts "#{"[E]".colorize(:light_red)} No cmd is set in Task."
          exit(1)
        end
      end
    rescue
    end
  else
    puts "#{"[E]".colorize(:light_red)} The format of the YAML file is incorrect."
    exit(1)
  end
end
