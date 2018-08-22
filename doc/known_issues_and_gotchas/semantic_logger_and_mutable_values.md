SemanticLogger and Mutable Values
==============================================================================

...or, "why are some of the custom field values wrong in my logs".

In it's default setup, Semantic Logger (SemLog) pushes log messages into a queue
from the origin thread and handles dispatching the messages, including
serializing data structures, asynchronously in another thread.

Log messages hold references to their custom field values, and those references
are moved with the log to the writer thread via the queue, meaning if the origin
thread mutates the values before the writer thread serializes the values, the
serialization in the log message will reflect changes to the value that happen
*after* it was logged, which can be horribly confusing if you're not aware of
it.

I dealt with a similar issue with logging to the JavaScript browser console,
where something like

    console.log( "Here's my object", obj );

results in the console showing an nice expandable view of the object *as it
is currently in memory*, which I guess makes some sense, but can be terribly
frustrating if don't realize it and are trying to log the state of a mutated
object over time.

Similar to that situation, I don't see much in the way of solutions accept to
do some additional amount of work in the origin thread before pushing the log
message to the queue:

1.  Serializing values pre-queue, which is problematic because they may be
    headed for multiple appenders that wish to serialize them differently.

2.  "Snapshotting" values, which can perhaps avoid much of the usual nasty edge
    cases because we know the value must be serialized anyways, but still seems
    like it would be quite a mess.

3.  Ditching the writer thread and queue and logging entirely in the origin
    thread before returning from the log call.

I added an option to {NRSER::Log.setup} and friends to switch to "sync" logging
from the default async approach, which solves most of my issues because the
places this was really causing me headaches were in CLI scripts that have little
or no need for the kind of speed a separate writer thread yields, and I've tried
to be aware of the issue and copy structures that will be mutated before passing
them off to the log calls in code that I don't know will run in that
configuration.
