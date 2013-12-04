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
