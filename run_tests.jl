include("helper_functions.jl")
using Distributed

# set up all the vms as distributed workers
vms = ["vm$i" for i in 0:4]
addprocs(vms[2:5])
for i in 2:5
  vms[i] = remotecall_fetch(gethostname, i)
end

# Experiment 0: Record machine details
for i in 1:5
  remotecall_wait(() -> run(`bash /home/L50/l50-tests/exp0.sh`), i)
end
println("Experiment 0 Complete")

# Experiment 1: RTT between all machines
for src in 1:5, dest in 1:5
  wait(ping(src, dest, `-f -c 1000`, "/home/L50/data/exp1/ping-$src-$dest"))
end
println("Experiment 1 Complete")

# Expermient 2: Traceroute between all machines
for src in 1:5, dest in 1:5
  wait(traceroute(src, dest, ``, "/home/L50/data/exp2/traceroute-$src-$dest"))
end
println("Experiment 2 Complete")

# Experiment 3: iperf between all machines (tcp)
for src in 1:5, dest in 1:5
  iperf(src, dest, `-t 10 -i 1 -f m`, ``, "/home/L50/data/exp3/iperf-$src-$dest")
end
println("Experiment 3 Complete")

# Experiment 4: bidirectional iperf between all machines (tcp)
for src in 1:5, dest in 1:5
  iperf(src, dest, `-d -t 10 -i 1 -f m`, ``, "/home/L50/data/exp4/iperf-$src-$dest")
end
println("Experiment 4 Complete")

# Experiment 5: iperf 1 to 2
for dest in [(i, j) for i in 2:5, j in 2:5 if i != j]
  dest1 = dest[1]
  dest2 = dest[2]
  src = 1
  iperf2dest(src, dest1, dest2, `-t 10 -i 1 -f m`, ``, "/home/L50/data/exp5")
end
println("Experiment 5 Complete")

# Experiment 6: iperf 2 to 1
for src in [(i, j) for i in 2:5, j in 2:5 if i != j]
  src1 = src[1]
  src2 = src[2]
  dest = 1
  iperf2src(dest, src1, src2, `-t 10 -i 1 -f m`, ``, "/home/L50/data/exp6")
end
println("Experiment 6 Complete")
