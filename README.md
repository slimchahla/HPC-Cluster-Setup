# HPC-Cluster-Setup
How to setup a HPC cluster using Warewulf and SLURM

## Table of Contents
- [What is HPC?](#what-is-hpc)
- [Who needs HPC?](#who-needs-HPC)
- [How can I measure the power of my system?](#how-can-i-measure-the-power-of-my-system)


### What is HPC?
High Performance Computing (HPC) typically refers to the act of using massively parallel computing on some type of system to perform computations very quickly. This can be done on a single system with a large amount of cores or on a cluster system made up of aggregated computers. The latter is what we will be exploring here.

### Who needs HPC?
When large amounts of data need to be crunched or some serious rendering needs to get done, a normal desktop doesn't cut it. A common use case of HPC is scientific computing such as physics simulations.

### How can I measure the power of my system?
In computing, the common measure of proccessing power is [FLOPS](https://en.wikipedia.org/wiki/FLOPS). The equation for calculating the FLOPS of a system is given as ![equation](https://wikimedia.org/api/rest_v1/media/math/render/svg/edfc49be7d1514d05e39d5d6d85a85ba8a9d67ee). Broken down it means:

*FLOPS* = *CPU count* x *Cores per CPU* x *Clock Speed of CPU in GHz* x *Instructions per cycle of CPU*

A 4790k provides peak performance of (1 CPU x 4 Cores x 4.0 GHz x 16) = 256 GFLOPS<br>
A dual socket E5-2690v3 provides peak performance of (2 CPU x 12 Cores x 2.6 GHz x 16) = 998.4 GFLOPS

When you begin combining computers (nodes) into a cluster, you just add up the flops per node. So a 4 node system of dual socket E5-2690v3 would provide (998.4 GFLOPS x 4) = 3993.6 GFLOPS or about 4 TFLOPS.

The numbers above represent double precision floating point arithmetic. It's important to remember that these numbers are theoretical due to limiting factors such as IO and needing to transfer data between nodes.

### Why not just use GPU for everything?
GPU computing allows massive amounts of number crunching to be performed. A [Quadro M6000](https://images.nvidia.com/content/pdf/quadro/data-sheets/NV-DS-Quadro-M6000-24GB-US-NV-fnl-HR.pdf) provides up to 3.5 TFLOPS of double precision performance. Thats almost as much as the 4 node dual socket E5-2690v3. Clearly the GPU is better right? The short answer is no because GPUs are only good for number crunching. Thats it. They can't do much else. The long answer is that GPUs have thousands of processors (the M6000 has 3072 cores) but they all run very slow compared to a standard CPU. A GPU is too slow for any normal serial operation. They also lack features vital to operating systems such as intterupts.

GPUs are still great tools for hardware accelerated computing. We can combine CPU and GPU to maximize our computing power.

### What is a cluster?
