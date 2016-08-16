## Task!

This is half a tool to help me track where my days go, and half an excuse to use the github API for something.

The API with (eventually) be:
```shell
⫸ task start "Some tasks that I'm switching to"
```
The first call to `task` for the day will create a new gist with today's date. A line item containing a timestamp and the provided message will be included in the gist. As more calls to `task` occur throughout the day, more line items will be appended to the gist.

At the end of the day, this gist can be sent to your producer so they know where your time went.

## System Requirements

- ruby >= 2.3.0

## TODO:

- [ ] `continue` with task id
- [ ] `info`
- [x] `delete`
- [ ] confirmation messages for `delete`
- [x] `list`
- [ ] `summary`
- [x] rename to `task`
- [ ] setup install

--------------------

### The MIT License (MIT)
#### Copyright (c) 2016 Mat Pataki

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
