require "./watch_process.cr"

def run_watcher(cmd, ignore_list, match_list, ext_list, env : Hash(String, String)? = nil)
  if env
    watch_process({cmd: cmd, env: env, ignore: ignore_list, match: match_list, ext: ext_list})
  else
    watch_process({cmd: cmd, ignore: ignore_list, match: match_list, ext: ext_list})
  end
end
