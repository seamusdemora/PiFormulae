## Ruminations on "block size"

I'll start off by saying that I am ***fuzzy*** on this "*block size*" business. The term is tossed about quite a lot in the literature and documentation for Linux; esp wrt filesystems and persistent storage media. 

I've been reading in an effort to educate myself on "block size". I found a [wiki article](https://wiki.linuxquestions.org/wiki/Block_devices_and_block_sizes) that seemed informative, but it is *dated*. An area where it's out-dated is wrt the `vmstat` utility; the wiki author says, **"`man vmstat` states: All linux blocks are currently 1024 bytes."** The `vmstat` manual does not say that any longer, but I don't know when the change was made.

Further reading suggested that `vmstat` actually has little to do with block devices (persistent storage media), and that the `blockdev` utility (p/o `util-linux` package) is now the *ticket* for questions re "block size". Reading through `man blockdev`, the term "sectors" is used frequently... And if I read correctly, the currently-favored term for the *atomic unit* of block storage devices is **"sector"** - **not "block"**. Or, is a *better way* to phrase this that a "sector" is a "physical block" (ref. `man blockdev` for option `--getpbsz`)? 

I wondered if things were coming into focus, but the use of the terms "sectors" and "blocks" seems *generally* inconsistent in the literature and documentation. The notion of using the term "sector" to designate a *hardware-based unit of storage*, and "block" to designate a *software-based, *variable* unit of storage* does **seem** logical. But is it correct? ... It's certainly not widely practiced! 

Further reading led me to [this answer on Apple SE](https://apple.stackexchange.com/a/260086/149366). It suggests that the "block"/"sector" size of (at least some) hardware can be changed (perhaps via *firmware*?). I considered this for a bit, and then concluded, "If the kernel knows the "block"/"sector" size of the device, then it can properly allocate inodes, assign metadata and do all the things that a filesystem must do."

I'm posting this in the hope that these "ruminations" might help someone else. Oh - speaking of `inode`s, this [Wikipedia article](https://en.wikipedia.org/wiki/Inode) was interesting: In 2002, Dennis Ritchie was asked about the origin of the term 'inode'... specifically, what did the "i" in 'inode' designate. He did not know the answer! :)  However, in the 1986 book "The Design of the Unix Operating System", author Maurice J. Bach wrote that the word *inode* "is a contraction of the term "index node", and is commonly used in literature on the UNIX system". Now you know! 

<!---

I'll start off by saying that I am ***fuzzy*** on this "*block size*" business. I say this up front to forestall answers that may assume I know *anything*! 

I've been reading in an effort to educate myself on this question. I found a [wiki article](https://wiki.linuxquestions.org/wiki/Block_devices_and_block_sizes) that seemed informative, but it is *dated*. An area where it's out-dated is wrt the `vmstat` utility; the wiki author says, **"`man vmstat` states: All linux blocks are currently 1024 bytes."** The `vmstat` manual does not say that any longer, but I don't know when the change was made.

Further reading suggested that `vmstat` actually has little to do with block devices (persistent storage media), and that the `blockdev` utility (p/o `util-linux` package) is now the *ticket* for questions re "block size". Reading through `man blockdev`, the term "sectors" is used frequently... And if I read correctly, the currently-favored term for the *atomic unit* of block storage devices is **"sector"** - **not "block"**. Or, is a *better way* to phrase this that a "sector" is a "physical block" (ref. `man blockdev` for option `--getpbsz`)? 

I wondered if things were coming into focus, but the use of the terms "sectors" and "blocks" seems *generally* inconsistent in the literature and documentation. The notion of using the term "sector" to designate a *hardware-based unit of storage*, and "block" to designate a *software-based, *variable* unit of storage* does **seem** logical. But is it correct?

Further reading led me to [this answer on Apple SE](https://apple.stackexchange.com/a/260086/149366). It suggests that the "block"/"sector" size of (at least some) hardware can be changed (perhaps via *firmware*?). I considered this for a bit, and then concluded, "If the kernel knows the "block"/"sector" size of the device, then it can properly allocate inodes, assign metadata and do all the things that a filesystem must do."

-->