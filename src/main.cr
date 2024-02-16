require "./libs/*"
require "./utils/*"
require "./modules/*"

args : Array(String) = ARGV

show_help if args.size == 1 && args.join(" ") =~ /^-(h|-help)$/
show_version if args.size == 1 && args.join(" ") =~ /^-(v|-version)$/
run_initialize if args.size == 1 && args.join(" ") =~ /^-(i|-init)$/

show_tasks(read_conf) if args.size == 0
run_task(read_conf, args) unless args.size == 0
