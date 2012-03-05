Xen Minimal OS
--------------

This shows some of the stuff that any guest OS will have to set up.

This includes:

 * installing a virtual exception table
 * handling virtual exceptions
 * handling asynchronous events
 * enabling/disabling async events
 * parsing start_info struct at start-of-day
 * registering virtual interrupt handlers (for timer interrupts)
 * a simple page and memory allocator

