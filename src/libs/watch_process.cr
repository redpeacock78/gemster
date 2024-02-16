require "colorize"

private def watch_files(args : NamedTuple(ignore: Array(String) | Array(YAML::Any), match: Array(String) | Array(YAML::Any), ext: Array(String) | Array(YAML::Any)))
  file_list : Array(String) = Dir.glob("./**/*").select { |file| File.file?(file) }
  Dir.glob("./**/**").select { |file| File.file?(file) }.map do |file|
    args[:ignore].map { |ignore|
      ignore.to_s.gsub(".", "\\.").gsub("/", "\\/").gsub("**", "*").sub(/^\*/, ".*")
    }.map { |ignore|
      file_list.delete(file) if file.match(/#{ignore}/)
    } if args[:ignore].size > 0
    args[:match].map { |match|
      match.to_s.gsub(".", "\\.").gsub("/", "\\/").gsub("**", "*").sub(/^\*/, ".*")
    }.map { |match|
      file_list.delete(file) if !file.match(/#{match}/)
    } if args[:match].size > 0
    args[:ext].map { |ext|
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

def watch_process(args)
  file_timestamps : Hash(String, String) = {} of String => String

  file_list : Array(String) = watch_files({ignore: args[:ignore], match: args[:match], ext: args[:ext]})
  path_list : Array(String) = path_list(file_list)
  ext_list : Array(String) = ext_list({ext: args[:ext], file_list: file_list})

  process : Process | Nil = nil

  puts "#{"[*]".colorize(:light_blue)} watching path(s): #{path_list.sort.uniq.join(",")}"
  puts "#{"[*]".colorize(:light_blue)} watching extensions: #{ext_list.sort.uniq.join(",")}"
  puts "#{"[!]".colorize(:light_yellow)} starting `#{args[:cmd]}`"

  process = Process.new(args[:cmd], shell: true, output: STDOUT, error: STDERR) if args[:env]? == nil
  process = Process.new(args[:cmd], env: args[:env]?, shell: true, output: STDOUT, error: STDERR) if args[:env]? != nil

  loop do
    begin
      file_list.map do |file|
        timestamp : String = File.info(file).modification_time.to_unix.to_s
        if file_timestamps[file]? && file_timestamps[file] != timestamp
          file_timestamps[file] = timestamp

          puts "#{"[*]".colorize(:light_blue)} restarting due to changes..."
          puts "#{"[*]".colorize(:light_blue)} watching path(s): #{path_list.sort.uniq.join(",")}"
          puts "#{"[*]".colorize(:light_blue)} watching extensions: #{ext_list.sort.uniq.join(",")}"
          puts "#{"[!]".colorize(:light_yellow)} starting `#{args[:cmd]}`"

          process.signal(:kill) unless process.terminated? if process.is_a? Process
          process = Process.new(args[:cmd], shell: true, output: STDOUT, error: STDERR) if args[:env]? == nil
          process = Process.new(args[:cmd], env: args[:env]?, shell: true, output: STDOUT, error: STDERR) if args[:env]? != nil
        else
          file_timestamps[file]? == nil
          file_timestamps[file] = timestamp
        end
      end
    rescue ex
      puts "#{"[E]".colorize(:light_red)} #{ex.message}"
    end
  end
end
