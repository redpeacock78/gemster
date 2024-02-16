def run_command(cmd : String, env : Hash(String, String)? = nil)
  if env
    Process.run(cmd, env: env, shell: true, output: STDOUT, error: STDERR)
  else
    Process.run(cmd, shell: true, output: STDOUT, error: STDERR)
  end
end
