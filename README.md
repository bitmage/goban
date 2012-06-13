### Goban

This is an HTML5 Go Board.  It's written in coffeescript and paper.js.  You can find a demo(tested in Chrome) at:

> [http://webgoban.com](http://webgoban.com)

It allows you to play both sides.  It should follow all the rules of Go.  If you find a bug, let me know!

## Goals

The main goal is to create open standards for Go and get away from the Java cruft that seems to permiate the online Go world.  I would like to use websockets to communicate to a node.js server, which may at some point wrap access to something like IGS.  The Internet Go Protocols reek of the EDI craze, which I think was designed to generate cash for specialty consulting firms.  See [this post](http://gnugos60.blogspot.com/2007/04/internet-go-protocols.html).

## TODO

* Refactor goban.coffee to be a constructor
* Clean up code
* Add a backend game server (node.js!)
* Build a complete UI for finding/playing games

## LICENSE

(MIT License)

Copyright (c) 2012 Bitmage <projects@bitmage.com>

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
