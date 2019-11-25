# Helper functions for experiments

vms = ["vm$i" for i in 0:4]

function ping(src, dest, flags, out)
  destname = vms[dest]
  return remotecall(run(pipeline(`ping $flags $destname`, stdout=out, stderr="/home/L50/errors.txt")), src)
end

function traceroute(src, dest, flags, out)
  destname = vms[dest]
  return remotecall(run(pipeline(`traceroute $flags $destname`, stdout=out, stderr="/home/L50/errors.txt")), src)
end

function iperf(src, dest, flags, serverflags, out)
  destname = vms[dest]
  srcname = vms[src]
  remotecall_wait(run(pipeline(`iperf -s -D $serverflags`, stdout="/dev/null", stderr="/home/L50/errors.txt")), dest)
  remotecall_wait(run(pipeline(`iperf -c $ip $flags`, stdout=out, stderr="/home/L50/errors.txt")), src)
  remotecall_wait(run(pipeline(`pkill iperf`), stdout="/dev/null", stderr="/home/L50/errors.txt"), dest)
end


