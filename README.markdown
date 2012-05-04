MPFoldTransition
=====================
MPFoldTransition is a set of classes to add folding-style transitions to iOS 5 projects.

I built it using ARC (and for the demo portion storyboards) strictly for convenience, so it uses iOS 5.  I imagine the relevant code (minus the UIStoryboardSegue helper classes) could be easily ported to iOS 4.3 under ARC, or ported to iOS 4.0 with memory management inserted.

Features
---------
Convenience methods to extend UIViewController and UINavigationController to easily present/dismiss a view controller modally or push it onto/pop it off of a navigation stack
Convenience methods to transition between any 2 UIViewControllers or UIViews
Fully customizable to adjust style, duration, timing curves, and completion action
Blocks-based: many methods include a completion block parameter following the pattern of block-based animations introduced in iOS 4.

Styles
---------
Currently there are 3 different style bits that can be combined for 8 different styles.
* Direction: Fold vs. Unfold
* Mode: Normal vs. Cubic
* Orientation: Vertical vs. Horizontal
