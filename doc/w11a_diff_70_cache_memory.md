## Known differences between w11a and KB11-C (11/70)

### No cache parity and minimal subset of memory system controls

The 11/70 provides extensive reliability and diagnostics features for the cache
and memory system. They are very specific to the concrete 11/70 implementation
and most can't be mapped to the w11 implementation. The w11 provides all
the cache and memory system control registers, but provides only a very
limited subset of the functionality:
- no cache parity, and therefore no vector 114 interrupts
- the cache hit/miss and memory size registers are implemented
  - 177752 memory system hit/miss register: gives hit/miss for last 6 accesses
  - 177760 memory system lower size register: gives size in clicks
- the memory system control register (177746) has limited functionality
  - the cache can be disabled, setting bit 2 or bit 3 will force a cache miss
  - bits 0,1,4, and 5 can be set and read back, but have no function
- the following registers return zero on reads and ignore writes
  - 177740 low error address register
  - 177742 high error address register
  - 177744 memory system errior register
  - 177750 memory system maintenance register
  - 177762 memory system upper size register
