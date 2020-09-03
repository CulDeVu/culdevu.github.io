== Sending strings
=== wip

A couple months back I was making a visualizer for some data that originated in one process and was transmitted to another process on the same computer for storage, visualization, comparison, etc. And back before that I was playing around with making a very basic debugger with the same structure. The general setup of the problem that I'm going to be talking about here goes like this:

There is a long-lived server that multiple clients *on the same computer* can connect and disconnect to, let's just say one at a time for simplicity. To communicate, some kind of very simple communication interface is chosen (named pipe, IOCP, shared memory + mutex, it doesn't really matter as long as it's a very simple read-linearly-write-linearly interface). The mechanism in the clients for generating data and then sending it needs to be pretty low latency. In addition to low CPU overhead, the clients also need to be pretty low memory overhead as well. The server needs to have some ability to recall any data that its been sent before, but there's no real requirement for the clients to remember anything that they've already sent.

Of the things that have to be sent from the client to the server, a majority is string data. These strings are medium size, maybe 60-100 bytes on average. The vast, vast majority of possible strings that can be sent from the clients to the server are known at the time the client connects, but there's a lot of possibilities. Definitely less than `2^32` of them, but certainly in the hundreds of thousands and maybe into the millions. An expected number of strings that are getting generated and needing to be sent should in the range of 50-100 per second maybe. These strings are NOT random, they're actually very heavily clumped usually (maybe only 100 or so unique strings ever need sending over the course of a minute), but the distribution of these strings can change slowly or it could change abruptly.

Now just given this information you could go to town and get this system running really smoothly. Normally I would too, but unfortunately I didn't have the time to sink into a side project. So this post isn't going to be about solving this really well (or even competently), it's about the thought-process that led to the simple implementation that I *did* write.

# section

There are a number of ways that come to mind for the first couple passes at this system. I was doing very little in the way of compression (well, you'll see), but if it bothers you just add compression on to the end of these options.

- **Option 1: Send the all the strings every time**. The simplest system. This version has the client refer to strings in-program as integer ids into a string table, and when it comes time to send data to the server you just send those ids along with the string table. Immediately after sending, the string table gets reset, along with the counter.
- **Option 2: Don't send all the strings every time**. Do the same thing with in-program ids, but don't send the entire string table along with the message. There now needs to be some system for the server and the client to square up on what the ids mean.

Let's go deeper in depth into that second one.

## Option 2.1

In this version of option 2, no strings are sent in the main messages, just string ids. A message then has to be sent from the server to the client asking for any strings that it doesn't recognize the ids of.

## Option 2.2

## Option 1