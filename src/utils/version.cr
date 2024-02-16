require "colorize"

def version
  version : String = {{ `shards version #{__DIR__}`.chomp.stringify }}
end

def show_version
  puts "#{File.basename(Process.executable_path.to_s)} v#{version}"
  exit(0)
end
