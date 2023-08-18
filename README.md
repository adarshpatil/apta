# ![Apta thumb](https://github.com/adarshpatil/timewarp/blob/master/images/projects/apta/apta-thumb-github.png) Fault-tolerant object-granular CXL.mem for FaaS

# What is Āpta?
Āpta is a fault-tolerant CXL-based, shared disaggregated memory system that is specialized as an object-store to improve performance of function-as-a-service (FaaS) applications. 

The full system design and specifications are available in our [DSN 2023 paper](https://users.cs.utah.edu/~vijay/papers/dsn23.pdf). 

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
	This repo contains architecture implementations of
	 - cxl-uncached: disable caching of all disaggregated memory data (no coherence required)
	 - cxl-baseline: 2 state (Valid/Invalida) coherence protocol 
	 - lazy-invalidation (Āpta protocol): cxl-baseline protocol with sharer invalidation out-of-the-critical path
2.  serverless benchmarks to run within the simulator\
	This repo contains refactored, shared memory implementations of serverless workflow benchmarks with
	 - python functions with object sharing using shared memory 
	 - python converted to C code using cython
	 - generated C code annotated with get / compute / put phases of execution
	 - traces generated with compiled C code using [VANDAL/Prism](https://github.com/adarshpatil/prism/tree/3a12d62cf622ac3918ff62f4265ce3457b48f7a4)
3.  Coherence protocol [specification](https://github.com/adarshpatil/apta/blob/main/Apta-DSN23-appendix.pdf) in table format.
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

# Trivia 
The name of the project - "Āpta" - is derived from the Sankrit word (आप्त) which means "trustworthy" or "reliable", referring here to the enhanced reliability provided by our system.
