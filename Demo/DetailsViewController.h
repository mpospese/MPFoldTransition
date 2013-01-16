//
//  DetailsViewController.h
//  MPFoldTransition (v 1.1.0)
//
//  Created by Mark Pospesel on 4/20/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import	"MPFoldEnumerations.h"

@interface DetailsViewController : UIViewController

@property (assign, nonatomic, getter = isFold) BOOL fold;
@property (assign, nonatomic) NSUInteger style;

- (IBAction)popPressed:(id)sender;

@end
