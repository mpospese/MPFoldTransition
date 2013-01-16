//
//  AboutViewController.h
//  MPFoldTransition (v 1.0.0)
//
//  Created by Mark Pospesel on 4/23/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MPModalViewControllerDelegate

// dimiss the modally presented view controller
- (void)dismiss;

@end

@interface AboutViewController : UIViewController

@property (weak, nonatomic) id<MPModalViewControllerDelegate> modalDelegate;

- (IBAction)donePressed:(id)sender;

@end
