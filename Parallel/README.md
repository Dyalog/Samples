Dyalog/Samples/Parallel
=======================

This folder contains code samples which illustrate the use of Futures and Isolates.

File              |Fn/Op/etc  |Comments             |
------------------|-----------|---------------------|
IIX.dyalog        |PEACH      |Cover for IÏX which optimises use of isolates and optionally displays a progress bar|
IIPageStats.Dyalog|Report     |Example which uses IIX.PEACH to analyse a large number of web pages|

IIX.PEACH
---------
`[left] (function[[callback][cblarg]] IIX.PEACH isolates) right`

Compared to the standard `IÏX` operator, `IIX.PEACH` provides functionality similar to that provided by the old `PEACH` operator from the experimental "parallel" workspace:

1. Instead of creating a new isolate for each function call, `IIX.PEACH` [re]uses a set of isolates, feeding each one another function call when it completes the preceeding one.
2. An optional callback function can be provided, it will be called each time a new function call is dispatched.
3. A default callback mechanism is provided, which displays a form with progress bars.

Arg/Operand   | Example      | Description          |
--------------|--------------|----------------------|
left, right   |              | operand arguments.    |
function      | 'foo'        | Must be a quoted character vector.
callback      | 'cb'         | Right argument will be a count of calls completed per isolate, plus the total number of calls started. Pass an empty vector ('') to get the progress form.|
cblarg        | 'Hello'   | Optional left argument to the callback function. If you use the default progress form, the value will be used as the caption.|
isolates      | ''<br>ns<br>isolates           | Empty vector to create (≢processors) empty isolates<br>Scalar namespace to create (≢processors) clones of ns<br>or: a Vector of pre-created isolates|

IIPageStats.Report
------------------
The "Report" function is intended as a simple but realistic example of the use of isolates via IIX.PEACH: The function takes a 2-letter US state code as the right argument, and returns a 2-column matrix with letter frequency counts from the front page of all major newspapers in that state. For example:
```
      IIPageStats.Report 'al'
 E 94540   
 T 73232   
 A 66385   
...down to...
 J  4225   
 Q  2216   
 Z  1143   
```

The function uses The US Newspaper List (http://USNPL-com) to find a list of major newspapers in the state named in the right argument. It then uses IIX.PEACH to process the the newspapers in parallel, using the default progress dialog so that you can track the progress visually.

An optional left argument allows you to set the number of isolates to use. Since these tasks ar highly I/O bound, it can be advantageous to run with a much higher number of isolates than the number of cores that is available on the machine - try 10 or 20, for example.

> Written with [StackEdit](https://stackedit.io/).
