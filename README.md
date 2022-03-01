# Yahoo! Bingo

Quite possible the oddest thing I've done recently.  I was writing a
toy program to teach myself Server Side Events, and I have no idea
why, but it really tickled my funny bone to write a Bingo client and
server, just as a demo of Server Side Events, using SSE to send Bingo
numbers out to players, but using plain ol' REST to tell the server
when someone had won.

I needed to come up with a protocol. Then I remember this program.  It
was written in Coffeescript, in 2013. Coffeescript was already out of
date by 2013.

So, what the heck, I decided to re-write the whole thing in
Typescript.

Funny thing, though: I actually have no way to test this.  `socket.io`
is deprecated due to a number of security issues, and the server Yahoo
set up for the contest has long been decommissioned. Looks like I'll
have to write that demo server twice-- once with SSE, once with
WebSockets (using the [ws](https://www.npmjs.com/package/ws) library).

And then I guess I'll have to write a blog post about it.

That's... let's see.  Two server, three clients.  (This is one of
them; an automated command-line client.  There should be an automated
SSE client for the SSE demo and, ultimately, a real-to-life playable
web client.)

---

## Original Readme:

Yahoo's running this contest.  Read about it here:
http://yahoobingo.herokuapp.com/

This took me about 40 minutes, total.  I was thinking about re-writing
this in Bacon, but my Bacon is pretty raw.  At best, I could
propertize the cards to create a new card (i.e. a new state) every
time a ball came in, but that seemed a little overwrought.  

It was nice to have an opportunity to hack Coffee and Node again.

I don't know that I trust Yahoo's server.  At least once I got back a
"you lost" signal from the server.  Since this client includes full
playback of every game, I could see that I had clearly won.
Unfortunately, my initial code assumed "lost" as the default state, so
I couldn't see if maybe the 'won' signal was lost before receiving the
disconnect.  I've changed that to 'playing,' so we can see that
condition now.
