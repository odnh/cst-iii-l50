# Helper functions for experiments

vms = ["vm$i" for i in 0:4]

function ping(src, dest, flags, out)
  destname = vms[dest]
  return remotecall(() -> run(pipeline(`sudo ping $flags $destname`, stdout=out, stderr="/home/L50/errors.txt")), src)
end

function traceroute(src, dest, flags, out)
  destname = vms[dest]
  return remotecall(() -> run(pipeline(`traceroute $flags $destname`, stdout=out, stderr="/home/L50/errors.txt")), src)
end

function iperf(src, dest, flags, serverflags, out)
  destname = vms[dest]
  srcname = vms[src]
  remotecall_wait(() -> run(pipeline(`iperf -s -D $serverflags`, stdout=devnull, stderr="/home/L50/errors.txt")), dest)
  remotecall_wait(() -> run(pipeline(`iperf -c $destname $flags`, stdout=out, stderr="/home/L50/errors.txt")), src)
  remotecall_wait(() -> run(pipeline(`pkill iperf`, stdout=devnull, stderr="/home/L50/errors.txt")), dest)
end


function iperf2dest(src, dest1, dest2, flags, serverflags, outdir)
  destname1 = vms[dest1]
  destname2 = vms[dest2]
  srcname = vms[src]
  out1 = "$outdir/iperf-$src-$dest1"
  out2 = "$outdir/iperf-$src-$dest2"
  remotecall_wait(() -> run(pipeline(`iperf -s -D $serverflags`, stdout=devnull, stderr="/home/L50/errors.txt")), dest1)
  remotecall_wait(() -> run(pipeline(`iperf -s -D $serverflags`, stdout=devnull, stderr="/home/L50/errors.txt")), dest2)
  i1 = remotecall(() -> run(pipeline(`iperf -c $destname $flags`, stdout=out1, stderr="/home/L50/errors.txt")), src)
  i2 = remotecall(() -> run(pipeline(`iperf -c $destname $flags`, stdout=out2, stderr="/home/L50/errors.txt")), src)
  wait(i1)
  wait(i2)
  remotecall_wait(() -> run(pipeline(`pkill iperf`, stdout=devnull, stderr="/home/L50/errors.txt")), dest1)
  remotecall_wait(() -> run(pipeline(`pkill iperf`, stdout=devnull, stderr="/home/L50/errors.txt")), dest2)
end

function iperf2src(dest, src1, src2, flags, serverflags, outdir)
  srcname1 = vms[src1]
  srcname2 = vms[src2]
  destname = vms[dest]
  out1 = "$outdir/iperf-$src1-$dest"
  out2 = "$outdir/iperf-$src2-$dest"
  remotecall_wait(() -> run(pipeline(`iperf -s -D $serverflags`, stdout=devnull, stderr="/home/L50/errors.txt")), dest)
  i1 = remotecall(() -> run(pipeline(`iperf -c $destname $flags`, stdout=out1, stderr="/home/L50/errors.txt")), src1)
  i2 = remotecall(() -> run(pipeline(`iperf -c $destname $flags`, stdout=out2, stderr="/home/L50/errors.txt")), src2)
  wait(i1)
  wait(i2)
  remotecall_wait(() -> run(pipeline(`pkill iperf`, stdout=devnull, stderr="/home/L50/errors.txt")), dest)
end
