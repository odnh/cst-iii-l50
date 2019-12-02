using Distributed

# set up all the vms as distributed workers (sequential to guarantee id)
vms = ["vm$i" for i in 0:4]
for i in 2:5 addprocs([vms[i]]) end
errfile = "/home/L50/errors.log"

# helper functions
function remoterun(cmd, outfile, errfile, loc)
  return () -> remotecall(() -> run(pipeline(cmd, stdout=outfile, stderr=errfile)), loc)
end

# Experiment 0: Record machine details
for i in 1:5
  cmd = `bash /home/L50/l50-tests/exp0.sh`
  wait(remoterun(cmd, devnull, devnull, i)())
end
println("Experiment 0 Complete")

# Experiment 1: RTT between all machines
for idx in [(i, j) for i in 1:5, j in 1:5 if i != j]
  src, dest = idx
  destname = vms[dest]
  intervals = [0.000001, 0.00001, 0.0001, 0.001, 0.01, 0.1]
  for interval in intervals
    flags = `-i $interval -c 100 -q`
    outfile = "/home/L50/data/exp1/ping-$src-$dest-$interval"
    cmd = `sudo ping $flags $destname`
    wait(remoterun(cmd, outfile, errfile, src)())
  end
end
println("Experiment 1 Complete")

# Experiment 2: Traceroute between all machines
for idx in [(i, j) for i in 1:5, j in 1:5 if i != j]
  src, dest = idx
  destname = vms[dest]
  outfile = "/home/L50/data/exp2/traceroute-$src-$dest"
  cmd = `traceroute $destname`
  wait(remoterun(cmd, outfile, errfile, src)())
end
println("Experiment 2 Complete")

# Experiment 3: iperf between all machines (tcp)
for idx in [(i, j) for i in 1:5, j in 1:5 if i != j]
  src, dest = idx
  destname = vms[dest]
  flags = `-t 10 -i 1 -f m`
  outfile = "/home/L50/data/exp3/iperf-$src-$dest"

  serverstartcmd = `iperf -s -D`
  clientcmd = `iperf -c $destname $flags`
  serverstopcmd = `pkill iperf`

  wait(remoterun(serverstartcmd, devnull, errfile, dest)())
  wait(remoterun(clientcmd, outfile, errfile, src)())
  wait(remoterun(serverstopcmd, devnull, errfile, dest)())
  sleep(1) # so pkill and server start don't interfere
end
println("Experiment 3 Complete")

# Experiment 4: iperf between all machines (udp)
for idx in [(i, j) for i in 1:5, j in 1:5 if i != j]
  src, dest = idx
  destname = vms[dest]
  flags = `-t 10 -i 1 -f m`

  serverstartcmd = `iperf -s -u -D`
  serverstopcmd = `pkill iperf`
  bandwidths = ["150m", "200m", "250m", "300m", "350m"]

  wait(remoterun(serverstartcmd, devnull, errfile, dest)())
  for bandwidth in bandwidths
    clientcmd = `iperf -u -c $destname -b $bandwidth $flags`
    outfile = "/home/L50/data/exp3/iperf-$src-$dest-$bandwidth"
    wait(remoterun(clientcmd, outfile, errfile, src)())
  end
  wait(remoterun(serverstopcmd, devnull, errfile, dest)())
  sleep(1)
end
println("Experiment 4 Complete")

# Experiment 5: bidirectional iperf between all machines (tcp)
for idx in [(i, j) for i in 1:5, j in 1:5 if i <= j]
  src, dest = idx
  destname = vms[dest]
  flags = `-t 10 -i 1 -f m -d`
  outfile = "/home/L50/data/exp5/iperf-$src-$dest"

  serverstartcmd = `iperf -s -D`
  clientcmd = `iperf -c $destname $flags`
  serverstopcmd = `pkill iperf`

  wait(remoterun(serverstartcmd, devnull, errfile, dest)())
  wait(remoterun(clientcmd, outfile, errfile, src)())
  wait(remoterun(serverstopcmd, devnull, errfile, dest)())
  sleep(1)
end
println("Experiment 5 Complete")

# Experiment 6: iperf 1 to 2
for dests in [(i, j) for i in 2:5, j in 2:5 if i <= j]
  src = 1
  flags = `-t 10 -i 1 -f m`

  # start servers
  for dest in unique(dests)
    wait(remoterun(`iperf -s -D`, devnull, errfile, dest)())
  end

  # client runs
  clientprocs = Array{Future,1}()
  for i in 1:length(dests)
    dest = dests[i]
    destname = vms[dest]
    push!(clientprocs, remoterun(`iperf -c $destname $flags`, "/home/L50/data/exp6/iperf-$src-$dest($i)-$dests", errfile, src)())
  end
  for clientproc in clientprocs
    wait(clientproc)
  end

  # shutdown servers
  for dest in unique(dests)
    wait(remoterun(`pkill iperf`, devnull, errfile, dest)())
  end
  sleep(1)
end
println("Experiment 6 Complete")

# Experiment 7: iperf 1 to 3
for dests in [(i,j,k) for i in 2:5, j in 2:5, k in 2:5 if i <= j && j <= k]
  src = 1
  flags = `-t 10 -i 1 -f m`

  # start servers
  for dest in unique(dests)
    wait(remoterun(`iperf -s -D`, devnull, errfile, dest)())
  end

  # client runs
  clientprocs = Array{Future,1}()
  for i in 1:length(dests)
    dest = dests[i]
    destname = vms[dest]
    push!(clientprocs, remoterun(`iperf -c $destname $flags`, "/home/L50/data/exp7/iperf-$src-$dest($i)-$dests", errfile, src)())
  end
  for clientproc in clientprocs
    wait(clientproc)
  end

  # shutdown servers
  for dest in unique(dests)
    wait(remoterun(`pkill iperf`, devnull, errfile, dest)())
  end
  sleep(1)
end
println("Experiment 7 Complete")
 
# Experiemnt 8: iperf 1 to 4
for dests in [(i,j,k,l) for i in 2:5, j in 2:5, k in 2:5, l in 2:5 if i <= j && j <= k && k <= l]
  src = 1
  flags = `-t 10 -i 1 -f m`

  # start servers
  for dest in unique(dests)
    wait(remoterun(`iperf -s -D`, devnull, errfile, dest)())
  end

  # client runs
  clientprocs = Array{Future,1}()
  for i in 1:length(dests)
    dest = dests[i]
    destname = vms[dest]
    push!(clientprocs, remoterun(`iperf -c $destname $flags`, "/home/L50/data/exp8/iperf-$src-$dest($i)-$dests", errfile, src)())
  end
  for clientproc in clientprocs
    wait(clientproc)
  end

  # shutdown servers
  for dest in unique(dests)
    wait(remoterun(`pkill iperf`, devnull, errfile, dest)())
  end
  sleep(1)
end
println("Experiment 8 Complete")

# Experiment 9: iperf 2 to 1
for srcs in [(i, j) for i in 2:5, j in 2:5 if i <= j]
  dest = 1
  destname = vms[dest]
  flags = `-t 10 -i 1 -f m`

  # start server
  wait(remoterun(`iperf -s -D`, devnull, errfile, dest)())

  # client runs
  clientprocs = Array{Future,1}()
  for src in srcs
    push!(clientprocs, remoterun(`iperf -c $destname $flags`, "/home/L50/data/exp9/iperf-$srcs-$src($i)-$dest", errfile, src)())
  end
  for clientproc in clientprocs
    wait(clientproc)
  end

  # shutdown servers
  wait(remoterun(`pkill iperf`, devnull, errfile, dest)())
  sleep(1)
end
println("Experiment 9 Complete")

# Experiment 10: iperf 3 to 1
for srcs in [(i, j, k) for i in 2:5, j in 2:5, k in 2:5 if i <= j && j <= k]
  dest = 1
  destname = vms[dest]
  flags = `-t 10 -i 1 -f m`

  # start server
  wait(remoterun(`iperf -s -D`, devnull, errfile, dest)())

  # client runs
  clientprocs = Array{Future,1}()
  for src in srcs
    push!(clientprocs, remoterun(`iperf -c $destname $flags`, "/home/L50/data/exp10/iperf-$srcs-$src($i)-$dest", errfile, src)())
  end
  for clientproc in clientprocs
    wait(clientproc)
  end

  # shutdown servers
  wait(remoterun(`pkill iperf`, devnull, errfile, dest)())
  sleep(1)
end
println("Experiment 10 Complete")

# Experiemnt 11: iperf 4 to 1
for srcs in [(i, j, k, l) for i in 2:5, j in 2:5, k in 2:5, l in 2:5 if i <= j && j <= k && k <= l]
  dest = 1
  destname = vms[dest]
  flags = `-t 10 -i 1 -f m`

  # start server
  wait(remoterun(`iperf -s -D`, devnull, errfile, dest)())

  # client runs
  clientprocs = Array{Future,1}()
  for src in srcs
    push!(clientprocs, remoterun(`iperf -c $destname $flags`, "/home/L50/data/exp11/iperf-$srcs-$src($i)-$dest", errfile, src)())
  end
  for clientproc in clientprocs
    wait(clientproc)
  end

  # shutdown servers
  wait(remoterun(`pkill iperf`, devnull, errfile, dest)())
  sleep(1)
end
println("Experiment 11 Complete")
