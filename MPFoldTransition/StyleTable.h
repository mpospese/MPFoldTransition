//
//  StyleTable.h
//  MPTransition (v 1.1.0)
//
//  Created by Mark Pospesel on 5/1/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StyleDelegate;
@interface StyleTable : UITableViewController

@property (assign, nonatomic, getter = isFold) BOOL fold;
@property (assign, nonatomic) NSUInteger style;
@property(weak, nonatomic) id<StyleDelegate> styleDelegate;
- (IBAction)donePressed:(id)sender;

@end

@protocol StyleDelegate <NSObject>

- (void)styleDidChange:(NSUInteger)newStyle;

@end
