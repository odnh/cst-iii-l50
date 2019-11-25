# Helper functions for experiments

vms = ["vm0", "vm1", "vm2", "vm3", "vm4"]
ips = ["10.0.0.5", "10.0.0.8", "10.0.0.4", "10.0.0.7", "10.0.0.6"]

function ping(dest, flags, out)
  ip = ips[dest]
  run(pipeline(`ping $flags $ip`, stdout=out, stderr="~/errors.txt"))
end

function pingall(src, flags, exp)
  out = "~/data/exp" + exp + "/"
  mkpath(out)
  dests = setdiff(collect(1:5), [src])
  for i in dests
    ping(dest, flags, out + "ping-"+src+"-"+i)
  end
end

function traceroute(dest, flags, out)
  ip = ips[dest]
  run(pipeline(`traceroute $flags $ip`, stdout=out, stderr="~/errors.txt"))
end

function tracerouteall(src, flags, exp)
  out = "~/data/exp" + exp + "/"
  mkpath(out)
  dests = setdiff(collect(1:5), [src])
  for i in dests
    traceroute(dest, flags, out + "traceroute-"+src+"-"+i)
  end
end

function iperfservstart(flags, out)
  run(pipeline(`iperf -s -D $flags`, stdout=out, stderr="~/errors.txt"))
end

function iperfservstop()
  run(pipeline(`pkill iperf`, stdout="~errors.txt", stderr="~/errors.txt"))
end

function iperf(dest, flags, out)
  ip = ips[dest]
  run(pipeline(`iperf -c $ip $flags`, stdout=out, stderr="errors.txt"))
end

function iperfall(src, flags, exp)
  out = "~/data/exp" + exp + "/"
  mkpath(out)
  dests = setdiff(collect(1:5), [src])
  for i in dests
    iperf(dest, flags, out + "iperf-"+src+"-"+i)
  end
end
