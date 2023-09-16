== Abstractions are logarithms
=== But often lead to larger codebases. Go figure.

Say you have some piece of software that reads PNG files from disk and displays them on the screen with X11. It was a pain to get it working properly, but it's finished. But now you want to support Win32 and Cocoa and JPEGs and GIFs! Pretty soon you have 9 pieces of code for displaying images:

- PNG with X11
- PNG with Win32
- PNG with Cocoa
- JPEG with X11
- JPEG with Win32
- JPEG with Cocoa
- GIF with X11
- GIF with Win32
- GIF with Cocoa

Of course, you could have also abstracted away the file and operating system specifics. We could write our software in such a way that it always converts images to a common simple file format, like RGB8. Then the appropriate operating system specific code reads from that common buffer in its own specific way.

With this, there are only 6 piece of code:

- PNG -> RGB8
- JPEG -> RGB8
- GIF -> RGB8
- RGB8 -> X11
- RGB8 -> Win32
- RGB8 -> Cocoa

Abstractions turn multiplications (`3 * 3 = 9`) into additions (`3 + 3 = 6`). Abstractions are logarithms.
