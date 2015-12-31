![Project logo](screenshots/bin_packing_logo.png?raw=true "Bin Packing Algorithms Demo Logo")

# Rectangle Bin Packing Demo

Demo of the Haxe rectangle [bin packing](https://github.com/Tw1ddle/Rectangle-Bin-Packing) algorithms [haxelib](http://lib.haxe.org/p/bin-packing). Try the live demo [in your browser](http://www.samcodes.co.uk/project/rectangle-bin-packing-demo/).

### Usage ###

This demo requires HaxeFlixel and the bin-packing haxelib, so install these first:

```bash
haxelib git flixel https://github.com/HaxeFlixel/flixel dev # Else try stable branch of HaxeFlixel: haxelib install flixel
haxelib install bin-packing
```

Build the app and repeatedly tap the buttons at the bottom of the "Game Substate" to test the packing algorithms. Tap the test button to run a battery of tests.

### Screenshots ###

![Screenshot](screenshots/screenshot1.png?raw=true "Bin Packing Algorithm Demo screenshot 1")

![Screenshot](screenshots/screenshot2.png?raw=true "Bin Packing Algorithm Demo screenshot 2")

### Notes ###
* This demo should work on all the Haxe targets that HaxeFlixel supports.
* The "OptimizedMaxRectsPacker" does not keep an occupancy measure, so it currently outputs 0% for occupancy.