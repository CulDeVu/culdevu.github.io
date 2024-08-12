== ??
=== wip

If you're watching the 2024 olympics on Peacock, there's this annoying gradiant effect whenever you pause or skip forwards or backwards:

[image]

It stays on the screen for like 5 full seconds. It's super annoying if you want to skip past people standing around, or you want to pause to read the score board or whatever.

##Instructions to disable it:

If you don't know what a bookmarklet is, it's a piece of javascript code stored in a bookmark. The idea is that you can execute a bit of custom code on any webpage you wanted by just clicking the bookmark while viewing that page. They were popular in the bad old days of lolcatz and cross-origin scripting. You could use them to link(http://kathack.com/)[play katamari on webpages] and a bunch of other silly stuff.

##Step 1: 

Bookmark this link:

<a href="javascript:document.getElementsByClassName('playback-overlay__container'')[0].style.background='none';">Bookmark me!</a>

You can do this by clicking and dragging it to your bookmarks bar, OR by right-clicking the link and adding it to your bookmarks.

##Step 2:

When the little "Add Bookmark" dialog comes up, give it a name like "Peacock Gradient Remover", and save it.

##Step 3:

Start watching one of the videos on Peacock. It doesn't matter if the video is playing or paused.

##Step 4:	

Click the bookmark you made in step 2. It may be in the bookmark bar, or (if you don't have an always-visible bookmark bar) by going into the hamburger icon -> Bookmarks -> Peacock Gradient Remover.

##Step 5:

Enjoy!

[image]

