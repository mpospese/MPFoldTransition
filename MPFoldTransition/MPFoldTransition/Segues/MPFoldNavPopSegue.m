//
//  MPFoldNavPopSegue.m
//  MPFoldTransition (v 1.0.0)
//
//  Created by Mark Pospesel on 4/18/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import "MPFoldNavPopSegue.h"
#import "MPFoldTransition.h"

@implementation MPFoldNavPopSegue

- (MPFoldStyle)defaultStyle
{
	return MPFoldStyleUnfold;
}

- (void)perform
{
    UIViewController *src = (UIViewController *) self.sourceViewController;
	UINavigationController *navController = src.navigationController;
	if (!navController)
		[NSException raise:@"Invalid Operation" format:@"MPFoldNavPopSegue can only be performed on a child controller of a UINavigationController."];
	if (![[navController visibleViewController] isEqual:src])
		[NSException raise:@"Invalid Operation" format:@"MPFoldNavPopSegue can only be performed from the current visibleViewController of a UINavigationController."];
	if ([navController.viewControllers count] < 2)
		[NSException raise:@"Invalid Operation" format:@"UINavigationController parent must have at least 2 child controllers in its stack.  Otherwise no pop can be performed."];
		
	[navController popViewControllerWithFoldStyle:[self style]];
}

@end
