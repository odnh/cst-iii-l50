# L50 - Test plan

Start: write script system that lets me run sets of tests between arbitrary machines at the same time

Things to test for: how the machines are actually set up/connected, limitations of the network, limitations of the vms network use

Tests to be bundled into a single runnable set so can be run in one go. If later configuration changes we will hopefully be able to see this in different results.

### General set up

1. Record the details of the current machine is use (ie cpu stats, memory stats, nic stats etc)
2. Ping between each machine to measure RTT (make as accurate as possible by redcing inter ping time and maybe reserving CPU).
3. Traceroute between each machine to check if more than one hop between any machines
4. Perform bandwidth test between individual machines (using iperf) and in both dirrections to check all link speeds and for symmetry.

### Network limitations

1. Multiple simultaneous throughput tests between different machines to see if there is any shared resource that impacts shared use. (Check for variability first)
2. Need to separate results for the above from the single machine not coping with doing two things at a time (ie is network of machine the limiting factor).
3. Use ping flooding to see when packets start dropping and assess whether this is the network of the machine that fails.
4. Use from more machines until the network starts dropping things.
5. Vary protocol in use to see if they are treated differently by the network (and if a high volume one starves a low volume on if this is not the case).
6. Vary MTU to see the maximum packet size supported by the network. Can try to infer underlying protocol from MTU (see azure docs)

7. Run multiple protocols at the same time to see if one can overtake another (if we are able to saturate a link to start with that is).
8. Try to perfom one-way tests to check for path asymmetry (will require some sort of clock sync)

NB: Need to figure about a way to differentiate limitations of the machine from limitations of the networko

Try to focus on more deeper eval than more experiments and more data (ie really dig into the resource sharing bit and the extensions of this. Will probably not get as far as the multi-protocol stuff. Put the asymmetry bit in general setup and its already sort of in other things anyway).
Also, ping flooding is probably a slightly pointless test.
Need to come up with number for number of times to run experiments etc... (with justification)
