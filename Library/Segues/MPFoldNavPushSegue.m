//
//  MPFoldNavPushSegue.m
//  MPFoldTransition (v 1.0.0)
//
//  Created by Mark Pospesel on 4/4/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import "MPFoldNavPushSegue.h"
#import "MPFoldTransition.h"
@implementation MPFoldNavPushSegue

- (void)perform
{
    UIViewController *src = (UIViewController *) self.sourceViewController;
    UIViewController *dest = (UIViewController *) self.destinationViewController;
	UINavigationController *navController = src.navigationController;
	if (!navController)
		[NSException raise:@"Invalid Operation" format:@"MPFoldNavPopSegue can only be performed on a child controller of a UINavigationController."];
    
	if (![[navController visibleViewController] isEqual:src])
		[NSException raise:@"Invalid Operation" format:@"MPFoldNavPopSegue can only be performed from the current visibleViewController of a UINavigationController."];
		
	[navController pushViewController:dest foldStyle:[self style]];
}

@end
