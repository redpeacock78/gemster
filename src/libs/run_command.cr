def run_command(cmd : String, env : Hash(String, String)? = nil)
  process : Process::Status | Nil = nil
  exit_code : Int32 | Nil = nil
  if env
    process = Process.run(cmd, env: env, shell: true, output: STDOUT, error: STDERR)
    exit_code = process.exit_code
    exit(exit_code)
  else
    process = Process.run(cmd, shell: true, output: STDOUT, error: STDERR)
    exit_code = process.exit_code
    exit(exit_code)
  end
end
