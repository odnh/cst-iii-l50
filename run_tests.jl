using Distributed

# set up all the vms as distributed workers (sequential to guarantee id)
vms = ["vm$i" for i in 0:4]
for i in 2:5 addprocs([vms[i]]) end
errfile = "/home/L50/errors.log"

# helper functions
function remoterun(cmd, outfile, errfile, loc)
  return () -> remotecall(() -> run(pipeline(cmd, stdout=outfile, stderr=errfile), loc))
end

# Experiment 0: Record machine details
for i in 1:5
  cmd = `bash /home/L50/l50-tests/exp0.sh`
  wait(remoterun(cmd, devnull, devnull, i)())
end
println("Experiment 0 Complete")

# Experiment 1: RTT between all machines
for locs in [(i, j) for i in 1:5, j in 1:5 if i !=j]
  src = locs[1]
  dest = locs[2]
  destname = vms[locs[2]]
  flags = `-i 0.01 -c 1000 -q`
  outfile = "/home/L50/data/exp1/ping-$src-$dest"
  cmd = `sudo ping $flags $destname`
  wait(remoterun(cmd, outfile, errfile, src)())
end
println("Experiment 1 Complete")

# Experiment 2: Traceroute between all machines
for idx in [(i, j) for i in 1:5, j in 1:5 if i != j]
  src, dest = idx
  outfile = "/home/L50/data/exp2/traceroute-$src-$dest"
  cmd = `traceroute $destname`
  wait(remoterun(cmd, outfile, errfile, src)())
end
println("Experiment 2 Complete")

# Experiment 3: iperf between all machines (tcp)
for idx in [(i, j) for i in 1:5, j in 1:5 if i != j]
  src, dest = idx
  flags = `-t 10 -i 1 -f m`
  outfile = "/home/L50/data/exp3/iperf-$src-$dest"

  serverstartcmd = `iperf -s -D`
  clientcmd = `iperf -c $destname $flags`
  serverstopcmd = `pkill iperf`

  wait(remoterun(serverstartcmd, devnull, errfile, dest)())
  wait(remoterun(clientcmd, outfile, errfile, src)())
  wait(remoterun(serverstopcmd, devnull, errfile, dest)())
end
println("Experiment 3 Complete")

# Experiment 4: bidirectional iperf between all machines (tcp)
for idx in [(i, j) for i in 1:5, j in 1:5 if i <= j]
  src, dest = idx
  flags = `-t 10 -i 1 -f m -d`
  outfile = "/home/L50/data/exp4/iperf-$src-$dest"

  serverstartcmd = `iperf -s -D`
  clientcmd = `iperf -c $destname $flags`
  serverstopcmd = `pkill iperf`

  wait(remoterun(serverstartcmd, devnull, errfile, dest)())
  wait(remoterun(clientcmd, outfile, errfile, src)())
  wait(remoterun(serverstopcmd, devnull, errfile, dest)())
end
println("Experiment 4 Complete")

# Experiment 5: iperf 1 to 2
for dests in [(i, j) for i in 2:5, j in 2:5 if i <= j]
  src = 1
  flags = `-t 10 -i 1 -f m`

  # start servers
  for dest in unique(dests)
    wait(remoterun(`iperf -s -D`, devnull, errfile, dest)())
  end

  # client runs
  clientprocs = zeros(length(dests))
  for i in 1:length(dests)
    dest = dests[i]
    destname = vms[dest]
    clientprocs[i] = remoterun(`iperf -c $destname $flags`, "/home/L50/data/exp5/iperf-$src-$dest($dests)", errfile, src)()
  end
  for clientproc in clientprocs
    wait(clientproc)
  end

  # shutdown servers
  for dest in unique(dests)
    wait(remoterun(`pkill iperf`, devnull, errfile, dest)())
  end
end
println("Experiment 5 Complete")

# Experiment 6: iperf 1 to 3
for dests in [(i,j,k) for i in 2:5, j in 2:5, k in 2:5 if i <= j && j <= k]
  src = 1
  flags = `-t 10 -i 1 -f m`

  # start servers
  for dest in unique(dests)
    wait(remoterun(`iperf -s -D`, devnull, errfile, dest)())
  end

  # client runs
  clientprocs = zeros(length(dests))
  for i in 1:length(dests)
    dest = dests[i]
    destname = vms[dest]
    clientprocs[i] = remoterun(`iperf -c $destname $flags`, "/home/L50/data/exp6/iperf-$src-$dest($dests)", errfile, src)()
  end
  for clientproc in clientprocs
    wait(clientproc)
  end

  # shutdown servers
  for dest in unique(dests)
    wait(remoterun(`pkill iperf`, devnull, errfile, dest)())
  end
end
println("Experiment 6 Complete")
 
# Experiemnt 7: iperf 1 to 4
for dests in [(i,j,k,l) for i in 2:5, j in 2:5, k in 2:5, l in 2:5 if i <= j && j <= k && k <= l]
  src = 1
  flags = `-t 10 -i 1 -f m`

  # start servers
  for dest in unique(dests)
    wait(remoterun(`iperf -s -D`, devnull, errfile, dest)())
  end

  # client runs
  clientprocs = zeros(length(dests))
  for i in 1:length(dests)
    dest = dests[i]
    destname = vms[dest]
    clientprocs[i] = remoterun(`iperf -c $destname $flags`, "/home/L50/data/exp7/iperf-$src-$dest($dests)", errfile, src)()
  end
  for clientproc in clientprocs
    wait(clientproc)
  end

  # shutdown servers
  for dest in unique(dests)
    wait(remoterun(`pkill iperf`, devnull, errfile, dest)())
  end
end
println("Experiment 7 Complete")

# Experiment 8: iperf 2 to 1
for srcs in [(i, j) for i in 2:5, j in 2:5 if i <= j]
  dest = 1
  destname = vms[dest]
  flags = `-t 10 -i 1 -f m`

  # start server
  wait(remoterun(`iperf -s -D`, devnull, errfile, dest)())

  # client runs
  clientprocs = zeros(length(srcs))
  for src in srcs
    clientprocs[i] = remoterun(`iperf -c $destname $flags`, "/home/L50/data/exp5/iperf-$src($srcs)-$dest", errfile, src)()
  end
  for clientproc in clientprocs
    wait(clientproc)
  end

  # shutdown servers
  wait(remoterun(`pkill iperf`, devnull, errfile, dest)())
end
println("Experiment 8 Complete")

# Experiment 9: iperf 3 to 1
for srcs in [(i, j, k) for i in 2:5, j in 2:5, k in 2:5 if i <= j && j <= k]
  dest = 1
  destname = vms[dest]
  flags = `-t 10 -i 1 -f m`

  # start server
  wait(remoterun(`iperf -s -D`, devnull, errfile, dest)())

  # client runs
  clientprocs = zeros(length(srcs))
  for src in srcs
    clientprocs[i] = remoterun(`iperf -c $destname $flags`, "/home/L50/data/exp9/iperf-$src($srcs)-$dest", errfile, src)()
  end
  for clientproc in clientprocs
    wait(clientproc)
  end

  # shutdown servers
  wait(remoterun(`pkill iperf`, devnull, errfile, dest)())
end
println("Experiment 9 Complete")

# Experiemnt 10: iperf 4 to 1
for srcs in [(i, j, k, l) for i in 2:5, j in 2:5, k in 2:5, l in 2:5 if i <= j && j <= k && k <= l]
  dest = 1
  destname = vms[dest]
  flags = `-t 10 -i 1 -f m`

  # start server
  wait(remoterun(`iperf -s -D`, devnull, errfile, dest)())

  # client runs
  clientprocs = zeros(length(srcs))
  for src in srcs
    clientprocs[i] = remoterun(`iperf -c $destname $flags`, "/home/L50/data/exp10/iperf-$src($srcs)-$dest", errfile, src)()
  end
  for clientproc in clientprocs
    wait(clientproc)
  end

  # shutdown servers
  wait(remoterun(`pkill iperf`, devnull, errfile, dest)())
end
println("Experiment 10 Complete")
