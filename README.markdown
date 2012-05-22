MPTransition
=====================
__Update__: MPTransition now comprises MPFoldTransition and MPFlipTransition

MPFoldTransition is a set of classes to add folding-style transitions to iOS 5 projects.  
![iPhone Fold](http://markpospesel.files.wordpress.com/2012/05/iphone-fold1.png)  
MPFlipTransition is a set of classes to add page-flipping transitions to iOS 5 projects.  
![iPhone Flip](http://markpospesel.files.wordpress.com/2012/05/iphone-flip-3.png)  
I built it using ARC (and for the demo portion storyboards) strictly for convenience, so it uses iOS 5.  I imagine the relevant code (minus the UIStoryboardSegue helper classes) could be easily ported to iOS 4.3 under ARC, or ported to iOS 4.0 with memory management inserted.  (_Hint:_ If you're porting to non-ARC, you'll need to retain [sourceView superView] in the init method.)

Features
---------
* Convenience methods to extend UIViewController to present/dismiss a view controller modally using fold/flip transitions
* Convenience methods to extend UINavigationController to push/pop view controllers onto the navigation stack using fold/flip transitions
* Convenience methods to transition between any 2 UIViewControllers or UIViews
* 3 Custom UIStoryboardSegue subclasses to easily add folding/flipping transitions via Interface Builder in your storyboards
* Fully customizable to adjust style, duration, timing curves, and completion action
* Blocks-based: many methods include a completion block parameter following the pattern of block-based animations introduced in iOS 4.

Fold Styles
---------
Currently there are 3 style bits that can be combined for 8 different styles.
* __Direction:__ Fold vs. Unfold  
![Fold vs. Unfold](http://markpospesel.files.wordpress.com/2012/05/fold-vs-unfold.png)  
* __Mode:__ Normal vs. Cubic  
![Normal vs. Cubic](http://markpospesel.files.wordpress.com/2012/05/normal-vs-cubic.png)  
* __Orientation:__ Vertical vs. Horizontal  
![Vertical vs. Horizontal](http://markpospesel.files.wordpress.com/2012/05/vertical-vs-horizontal.png)  

Flip Styles
---------
Currently there are 3 style bits that can be combined for 8 different styles.
* __Direction:__ Forward vs. Backward  
![Forward vs. Backward](http://markpospesel.files.wordpress.com/2012/05/forward-vs-backward-3.png)  
* __Orientation:__ Horizontal vs. Vertical  
![Horizontal vs. Vertical](http://markpospesel.files.wordpress.com/2012/05/horizontal-vs-vertical-3.png)  
* __Perspective:__ Normal vs. Reverse  
![Normal vs. Reverse](http://markpospesel.files.wordpress.com/2012/05/normal-vs-reverse-3.png)  

How To Use
---------
See the "MPFoldTransition.h" (and "MPFlipTransition.h") header file(s) for methods and use the demo project as a reference.  The Segue classes (under directory of the same name) are optional, only if you want to include storyboard support.  Otherwise you just need the classes under the bottommost MPFoldTransition directory.

Licensing
---------
Read Source Code License.rtf, but the gist is:
* Anyone can use it for any type of project
* All I ask for is attribution somewhere

Best,  
Mark Pospesel

Website: http://markpospesel.com/  
Contact: http://markpospesel.com/about  
Twitter: http://twitter.com/mpospese  
Hire Me: http://crazymilksoftware.com/  
