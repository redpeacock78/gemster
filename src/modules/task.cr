require "colorize"
require "../libs/*"

private def start_task_message(task_name, dep_task_name, cmd, watch_status = false)
  name : String = dep_task_name.size > 0 ? "#{File.basename(Process.executable_path.to_s)} #{dep_task_name}" : "#{cmd}"
  puts "#{"Task".colorize(:light_green)} #{task_name.colorize(:cyan)} #{name.colorize(:light_gray)}"
  puts "#{"[*]".colorize(:light_blue)} v#{version}"
  puts "#{"[!]".colorize(:light_yellow)} Commands to execute: `#{cmd.colorize(:cyan)}`" if dep_task_name.size > 0 && watch_status == false
end

def show_tasks(yml : YAML::Any)
  check_syntax({yml: yml})
  tasks : YAML::Any = yml["tasks"]
  message : String = "#{"💎 Available Tasks".colorize.bright}\n"
  tasks.as_h.keys.map do |key|
    desc : String = tasks[key]["desc"]? ? "  #{tasks[key]["desc"]?.to_s}" : ""
    cmd : String = ""
    if tasks[key]["cmd"]?
      cmd = tasks[key]["cmd"]?.to_s
      cmd = cmd.index("\n") != nil ? cmd.split("\n").reject { |i| i.empty? }.map { |i| "#{"    $ #{i}".colorize(:light_gray)}" }.join("\n") : "#{"    $ #{cmd}".colorize(:light_gray)}"
    else
      begin
        cmd = "#{tasks[key]["deps"].as_a.map { |i| "    > #{i}" }.join("\n").colorize(:light_gray)}"
      rescue
        cmd = "#{"    > #{tasks[key]["deps"]}".colorize(:light_gray)}"
      end
    end
    task_name : String = "#{"• #{key.colorize(:light_blue)}"}"
    message += desc.size > 0 ? "#{task_name}\n#{desc}\n#{cmd}\n" : "#{task_name}\n#{cmd}\n"
  end
  puts "#{"[*]".colorize(:light_blue)} v#{version}"
  puts message
end

def run_task(yml : YAML::Any, args : Array(String))
  task_name : String = args[0]
  check_syntax({yml: yml, task: task_name})
  cmd : String = ""
  dep_task_name : String | Array(String) = ""
  if yml["tasks"][task_name]["cmd"]? != nil
    cmd = yml["tasks"][task_name]["cmd"].to_s
  else
    begin
      dep_task_name = yml["tasks"][task_name]["deps"].to_s
      cmd = yml["tasks"][dep_task_name]["cmd"].to_s
    rescue
      dep_task_name = yml["tasks"][task_name]["deps"].as_a.map { |i| i.to_s }
      cmd = dep_task_name.map { |i| yml["tasks"][i]["cmd"].to_s }.join(" && ")
      dep_task_name = dep_task_name.join(" ")
    end
  end
  cmd_args : String = ""
  if args.size > 1
    args.shift
    cmd_args = " #{args.join(" ")}"
  end

  cmd = "#{cmd.gsub(/\\\n/, "").gsub("\n", "; ").sub(/; $/, "")}#{cmd_args}"

  env : Hash(String, String) | Nil = nil
  begin
    env = ENV.keys.map { |key| [key, ENV[key]] }.to_h
    if yml["tasks"][task_name]["env"]? != nil
      env = yml["tasks"][task_name]["env"].as_h.map { |key, val| [key.to_s, val.to_s] }.to_h.merge(env)
    elsif yml["tasks"][yml["tasks"][task_name]["deps"]?]["env"]? != nil
      env = yml["tasks"][yml["tasks"][task_name]["deps"]?]["env"].as_h.map { |key, val| [key.to_s, val.to_s] }.to_h.merge(env)
    end
  rescue
  end

  if yml["tasks"][task_name]["watch"]? != nil && yml["tasks"][task_name]["watch"]? == true
    start_task_message(task_name, dep_task_name, cmd, true)
    ext_list : Array(String) | Array(YAML::Any) = yml["tasks"][task_name]["ext"]? != nil ? yml["tasks"][task_name]["ext"].as_a : [] of String
    match_list : Array(String) | Array(YAML::Any) = yml["tasks"][task_name]["match"]? != nil ? yml["tasks"][task_name]["match"].as_a : [] of String
    ignore_list : Array(String) | Array(YAML::Any) = yml["tasks"][task_name]["ignore"]? != nil ? yml["tasks"][task_name]["ignore"].as_a : [] of String
    env != nil ? run_watcher(cmd, ignore_list, match_list, ext_list, env) : run_watcher(cmd, ignore_list, match_list, ext_list)
  else
    start_task_message(task_name, dep_task_name, cmd)
    env != nil ? run_command(cmd, env) : run_command(cmd)
  end
end
