include("helper_functions.jl")
using Distributed

# set up all the vms as distributed workers
vms = ["vm0", "vm1", "vm2", "vm3", "vm4"]
addprocs(vms)

run(pipeline(`hostname`, stdout="~/data/test1"))

# Experiment 0: Record machine details
for i in 1:5
  remotecall_wait(() -> run(`bash ~/l50-tests/exp0.sh`), i)
end

# Experiment 1: RTT between all machines
for i in 1:5
  remotecall_wait(() -> pingall(i, "-c 1000 -f", 1), i)
end

# Expermient 2: Traceroute between all machines
for i in 1:5
  remotecall_wait(() -> tracerouteall(i, "", 1), i)
end

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

# Experiment 4: iperf 1 to 2


# Experiment 5: iperf 2 to 1
