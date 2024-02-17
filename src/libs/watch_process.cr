require "colorize"

private def watch_files(args : NamedTuple(ignore: Array(String) | Array(YAML::Any), match: Array(String) | Array(YAML::Any), ext: Array(String) | Array(YAML::Any)))
  file_list : Array(String) = Dir.glob("./**/*").select { |file| File.file?(file) }
  Dir.glob("./**/**").select { |file| File.file?(file) }.each do |file|
    args[:ignore].map { |ignore|
      ignore.to_s.gsub(".", "\\.").gsub("/", "\\/").gsub("**", "*").sub(/^\*/, ".*")
    }.each { |ignore|
      file_list.delete(file) if file.match(/#{ignore}/)
    } if args[:ignore].size > 0
    args[:match].map { |match|
      match.to_s.gsub(".", "\\.").gsub("/", "\\/").gsub("**", "*").sub(/^\*/, ".*")
    }.each { |match|
      file_list.delete(file) if !file.match(/#{match}/)
    } if args[:match].size > 0
    args[:ext].each { |ext|
      file_list.delete(file) unless file.match(/#{ext}$/)
    } if args[:ext].size > 0
  end
  file_list
end

private def path_list(file_list : Array(String))
  file_list.map { |file|
    File.dirname(file)
  }.map { |path|
    path.sub(/^\.$/) { "./*" }
  }
end

private def ext_list(args : NamedTuple(ext: Array(String) | Array(YAML::Any), file_list: Array(String)))
  ext_list : Array(String) = [] of String
  ext_list = args[:ext].map { |ext| ext.to_s } if args[:ext].size > 0
  ext_list = args[:file_list].map { |file|
    File.extname(file).sub(".") { "" }
  }.reject { |ext|
    ext.empty?
  } unless args[:ext].size > 0
  ext_list
end

private def watch_message(path_list : Array(String), ext_list : Array(String), cmd : String, status : Bool = false)
  puts "#{"[*]".colorize(:light_blue)} restarting due to changes..." if status
  puts "#{"[*]".colorize(:light_blue)} watching path(s): #{path_list.join(", ")}"
  puts "#{"[*]".colorize(:light_blue)} watching extensions: #{ext_list.join(", ")}"
  puts "#{"[!]".colorize(:light_yellow)} starting `#{cmd}`"
end

def watch_process(args)
  file_timestamps : Hash(String, String) = {} of String => String

  file_list : Array(String) = watch_files({ignore: args[:ignore], match: args[:match], ext: args[:ext]})
  path_list : Array(String) = path_list(file_list).sort.uniq
  ext_list : Array(String) = ext_list({ext: args[:ext], file_list: file_list}).sort.uniq

  watch_message(path_list, ext_list, args[:cmd])

  process : Process | Nil = nil
  process = Process.new(args[:cmd], shell: true, output: STDOUT, error: STDERR) if args[:env]? == nil
  process = Process.new(args[:cmd], env: args[:env]?, shell: true, output: STDOUT, error: STDERR) if args[:env]? != nil

  loop do
    begin
      file_list.each do |file|
        timestamp : String = File.info(file).modification_time.to_unix.to_s
        if file_timestamps[file]? && file_timestamps[file] != timestamp
          file_timestamps[file] = timestamp

          watch_message(path_list, ext_list, args[:cmd], true)

          process.signal(:kill) unless process.terminated? if process.is_a? Process
          process = Process.new(args[:cmd], shell: true, output: STDOUT, error: STDERR) if args[:env]? == nil
          process = Process.new(args[:cmd], env: args[:env]?, shell: true, output: STDOUT, error: STDERR) if args[:env]? != nil
        else
          file_timestamps[file] = timestamp
        end
      end
    rescue ex
      puts "#{"[E]".colorize(:light_red)} #{ex.message}"
      exit(1)
    ensure
      sleep 0.5
    end
  end
end
