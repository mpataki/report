### Report!

This is half a tool to help me track where my days go, and half an excuse to use the github API for something.

The API with (eventually) be:
```shell
report 'Some tasks that I'm switching to'
```
The first call to `report` for the day will create a new gist with today's date. A line item containing a timestamp and the provided message will be included in the gist. As more calls to `report` occur throughout the day, more line items will be appended to the gist.

At the end of the day, this gist can be sent to your producer so they know where your time went (you're welcome Paul ;).

