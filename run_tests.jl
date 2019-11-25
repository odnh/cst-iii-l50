include("helper_functions.jl")
using Distributed

# set up all the vms as distributed workers
vms = ["vm$i" for i in 0:4]
addprocs(vms[2:5])

# Experiment 0: Record machine details
for i in 1:5
  remotecall_wait(() -> run(`bash /home/L50/l50-tests/exp0.sh`), i)
end
println("Experiment 0 Complete")

# Experiment 1: RTT between all machines
for i in 1:5
  remotecall_wait(() -> pingall(i, "-c 1000 -f", 1), i)
end
for src in 1:5, dest in 1:5
  wait(ping(src, dest, "-f -c 1000", "/home/L50/data/exp1/ping-$src-$dest"))
end
println("Experiment 1 Complete")

# Expermient 2: Traceroute between all machines
for src in 1:5, dest in 1:5
  wait(traceroute(src, dest, "", "/home/L50/data/exp2/traceroute-$src-$dest"))
end
println("Experiment 2 Complete")

# Experiment 3: iperf between all machines (tcp)
for src in 1:5, dest in 1:5
  iperf(src, dest, "", "", "/home/L50/data/exp3/iperf-$src-$dest")
end
println("Experiment 3 Complete")

# Experiment 4: iperf 1 to 2


# Experiment 5: iperf 2 to 1
