//
//  MPFlipSegue.m
//  MPTransition (v 1.1.0)
//
//  Created by Mark Pospesel on 4/18/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import "MPFlipSegue.h"
#import "MPFlipTransition.h"

#pragma mark - superclass

@implementation MPFlipSegue

@synthesize style = _style;

- (id)init
{
	self = [super init];
	if (self)
	{
		[self doInit];
	}
	
	return self;
}

- (id)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
	self = [super initWithIdentifier:identifier source:source destination:destination];
	if (self)
	{
		[self doInit];
	}
	
	return self;
}

- (void)doInit
{
	_style = [self defaultStyle];
}

- (MPFlipStyle)defaultStyle
{
	return MPFlipStyleDefault;
}

- (void)perform
{
	[NSException raise:@"Incomplete Implementation" format:@"MPFlipSegue must be subclassed and the perform method implemented."];
}

@end

#pragma mark - subclasses

@implementation MPFlipModalSegue

- (void)perform
{
	[self.sourceViewController presentViewController:self.destinationViewController flipStyle:[self style] completion:nil];
}

@end

@implementation MPFlipNavPushSegue

- (void)perform
{
    UIViewController *src = (UIViewController *) self.sourceViewController;
    UIViewController *dest = (UIViewController *) self.destinationViewController;
	UINavigationController *navController = src.navigationController;
	if (!navController)
		[NSException raise:@"Invalid Operation" format:@"MPFlipNavPopSegue can only be performed on a child controller of a UINavigationController."];
    
	if (![[navController visibleViewController] isEqual:src])
		[NSException raise:@"Invalid Operation" format:@"MPFlipNavPopSegue can only be performed from the current visibleViewController of a UINavigationController."];
	
	[navController pushViewController:dest flipStyle:[self style]];
}

@end

@implementation MPFlipNavPopSegue

- (MPFlipStyle)defaultStyle
{
	return MPFlipStyleDirectionBackward;
}

- (void)perform
{
    UIViewController *src = (UIViewController *) self.sourceViewController;
	UINavigationController *navController = src.navigationController;
	if (!navController)
		[NSException raise:@"Invalid Operation" format:@"MPFlipNavPopSegue can only be performed on a child controller of a UINavigationController."];
	if (![[navController visibleViewController] isEqual:src])
		[NSException raise:@"Invalid Operation" format:@"MPFlipNavPopSegue can only be performed from the current visibleViewController of a UINavigationController."];
	if ([navController.viewControllers count] < 2)
		[NSException raise:@"Invalid Operation" format:@"UINavigationController parent must have at least 2 child controllers in its stack.  Otherwise no pop can be performed."];
	
	[navController popViewControllerWithFlipStyle:[self style]];
}

@end
