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
println("Experiment 1 Complete")

# Expermient 2: Traceroute between all machines
for i in 1:5
  remotecall_wait(() -> tracerouteall(i, "", 1), i)
end
println("Experiment 2 Complete")

# Experiment 3: iperf between all machines (tcp)
for i in 1:5
  remotecall_wait(() -> iperfservstart("/dev/null", ""), i)
end
for i in 1:5
  remotecall_wait(() -> iperfall(i, "", 1), i)
end
for i in 1:5
  remotecall_wait(() -> iperfservstop(), i)
end
println("Experiment 3 Complete")

# Experiment 4: iperf 1 to 2


# Experiment 5: iperf 2 to 1
