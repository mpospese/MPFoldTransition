//
//  MPFlipSegue.h
//  MPTransition (v 1.1.0)
//
//  Created by Mark Pospesel on 4/18/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

// You must subclass this class, it performs no segue on its own

#import <UIKit/UIKit.h>
#import "MPFlipEnumerations.h"

#pragma mark - superclass

@interface MPFlipSegue : UIStoryboardSegue

@property (assign, nonatomic) MPFlipStyle style;

- (void)perform;

@end

#pragma mark - subclasses

@interface MPFlipModalSegue : MPFlipSegue

@end

@interface MPFlipNavPushSegue : MPFlipSegue

@end

@interface MPFlipNavPopSegue : MPFlipSegue

@end
