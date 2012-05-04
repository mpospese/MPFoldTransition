//
//  ViewController.h
//  MPFoldTransition (v 1.0.0)
//
//  Created by Mark Pospesel on 4/20/12.
//  Copyright (c) 2012 Odyssey Computing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AboutViewController.h"
#import "MPFoldEnumerations.h"
#import "StyleTable.h"

@interface ViewController : UIViewController<MPModalViewControllerDelegate, UIPopoverControllerDelegate, StyleDelegate>

@property (assign, nonatomic) MPFoldStyle style;

@property (weak, nonatomic) IBOutlet UIView *contentView;

- (IBAction)stepperValueChanged:(id)sender;
- (IBAction)stylePressed:(UIBarButtonItem *)sender;
//- (IBAction)infoPressed:(id)sender;

@end
