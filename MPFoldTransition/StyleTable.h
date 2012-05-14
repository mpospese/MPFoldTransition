//
//  StyleTable.h
//  MPFoldTransition (v 1.0.0)
//
//  Created by Mark Pospesel on 5/1/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPFoldEnumerations.h"

@protocol StyleDelegate;
@interface StyleTable : UITableViewController

@property (assign, nonatomic) MPFoldStyle style;
@property(weak, nonatomic) id<StyleDelegate> styleDelegate;
- (IBAction)donePressed:(id)sender;

@end

@protocol StyleDelegate <NSObject>

- (void)styleDidChange:(MPFoldStyle)newStyle;

@end
