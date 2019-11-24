using Distributed

# set up all the vms as distributed workers
vms = ["vm0", "vm1", "vm2", "vm3", "vm4"]
addprocs(vms)


