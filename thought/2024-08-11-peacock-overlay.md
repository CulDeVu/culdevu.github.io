== Peacock gradient overlay
=== Just a code snippet

If you're watching the 2024 olympics on Peacock, there's this annoying gradiant effect whenever you pause or skip forwards or backwards:

img(before.jpg)[Ugly black gradient, obscures what's going on at the bottom of the screen]

It stays on the screen for like 5 full seconds. It's super annoying if you want to skip past people standing around, or you want to pause to read the score board or whatever.

##Instructions to disable it:

If you don't know what a bookmarklet is, it's a piece of javascript code stored in a bookmark. The idea is that you can execute a bit of custom code on any webpage you want by just clicking the bookmark while viewing that page. They were popular in the bad old days of lolcatz and cross-origin scripting. You could use them to link(http://kathack.com/)[play katamari on webpages] and a bunch of other silly stuff.

##Step 1: 

Bookmark this link:

<a href="javascript:(function(){document.getElementsByClassName('playback-overlay__container')[0].style.background='none';})();">Peacock Gradient Remover</a>

You can do this by clicking and dragging it to your bookmarks bar, OR by right-clicking the link and adding it to your bookmarks.

I would say something like "watch out, some bookmarklets can be malicious", but you know what? The internet is could stand to be more exiting.

##Step 2:

Start watching one of the videos on Peacock. It doesn't matter if the video is playing or paused.

##Step 3:	

Click the bookmark you made in step 1. It may be in the bookmark bar, or (if you don't have an always-visible bookmark bar) by going into the hamburger icon -> Bookmarks -> Peacock Gradient Remover.

##Step 4:

Enjoy!

img(after.jpg)[Much better!]

Now if only we could get the directors to show us the actual athletes while they're doing their performance, and not the faces of the coaches and audience reacting to stuff we're missing.

