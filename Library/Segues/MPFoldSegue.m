//
//  MPFoldSegue.m
//  MPFoldTransition (v 1.0.0)
//
//  Created by Mark Pospesel on 4/18/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import "MPFoldSegue.h"

@implementation MPFoldSegue

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

- (MPFoldStyle)defaultStyle
{
	return MPFoldStyleDefault;
}

@end
