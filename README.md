# ![Apta thumb](https://github.com/adarshpatil/timewarp/blob/master/images/projects/apta/apta-thumb-github.png) Fault-tolerant object-granular CXL.mem for FaaS

Āpta is a fault-tolerant CXL-based, shared disaggregated memory system that is specialized as an object-store to improve performance of function-as-a-service (FaaS) applications. [[DSN '23 paper]](). 

This repository contains all artifacts used to experimentally evaluate Āpta 

# Features and properties of Āpta
### What does it provide?

- Higher performance than Amazon S3, Amazon ElastiCache, RDMA-based in-memory object store.
- Highest compute-server fault-tolerance, similar to as Amazon S3
- Strongly consistent object store and strict recovery semantics
- Flexible, dynamic schedulability of individual functions
- Lowers tail latency for function executions

### How does it achieve it?

- Uses CXL 3.0 shared disaggregated memory to hold shared FaaS objects in a memory server
- Builds over the CXL.mem protocol to create object granularity read/write semantics and allow object caching in compute servers
- Transforms the CXL.mem protocol into a high-available one using lazy (asynchronous) invalidations and coherence-aware scheduling
- Architects data place controllers on the memory and compute servers 
- Designs the control-plane software components

# Repository contents
1.  gem5 based implementation of CXL disaggregated memory (forked from [VANDAL/SynchroTrace-gem5](https://github.com/VANDAL/SynchroTrace-gem5))\
	This repo contains implementation of
	 - cxl-uncached: disable caching of all disaggregated memory data (no coherence required)
	 - cxl-baseline: 2 state (Valid/Invalida) coherence protocol 
	 - lazy-invalidation (Āpta protocol): cxl-baseline protocol with sharer invalidation out-of-the-critical path 

2.  serverless benchmarks to run within the simulator
	This repo contains refactored shared memory implementation of serverless benchmarks workflows with
	  - 

3.  Coherence protocol [specification]() in table format.

4.  [Murphi model](https://github.com/adarshpatil/apta/tree/main/murphi-model) for the Āpta protocol (generated using [ProtoGen](https://github.com/icsa-caps/ProtoGen))

# Additional Material
- FAQ, pdf, slides - https://adar.sh/apta

# Referencing our work
If you are using Āpta for your work, please cite:

```
@inproceedings{apta-dsn23,
	author = {Patil, Adarsh and Nagarajan, Vijay and Nikoleris, Nikos and Oswald, Nicolai},
	title = {Apta: Fault-tolerant object-granular CXL disaggregated memory for accelerating FaaS},
	year = {2023},
	publisher = {},
	booktitle = {Proceedings of the IEEE/IFIP 53rd Annual International Conference on Dependable Systems and Networks},
	pages = {},
	numpages = {15},
	keywords = {},
	series = {DSN '23}
}
```

--------------------------------------------------------------
The name of the project - Āpta - is derived from the Sankrit word (आप्त) which means "trustworthy" or "reliable", referring here to the enhanced reliability provided by our system.
