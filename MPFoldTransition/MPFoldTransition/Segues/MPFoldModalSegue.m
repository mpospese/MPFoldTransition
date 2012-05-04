//
//  MPFoldModalSegue.m
//  MPFoldTransition (v 1.0.0)
//
//  Created by Mark Pospesel on 4/18/12.
//  Copyright (c) 2012 Odyssey Computing. All rights reserved.
//

#import "MPFoldModalSegue.h"
#import "MPFoldTransition.h"

@implementation MPFoldModalSegue

- (void)perform
{
	[self.sourceViewController presentViewController:self.destinationViewController foldStyle:[self style] completion:nil];
}

@end
