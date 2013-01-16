//
//  ViewController.h
//  MPTransition (v 1.1.0)
//
//  Created by Mark Pospesel on 4/20/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AboutViewController.h"
#import "MPFoldEnumerations.h"
#import "MPFlipEnumerations.h"
#import "StyleTable.h"

enum {
	MPTransitionModeFold,
	MPTransitionModeFlip
} typedef MPTransitionMode;

@interface ViewController : UIViewController<MPModalViewControllerDelegate, UIPopoverControllerDelegate, StyleDelegate>

@property (assign, nonatomic) MPTransitionMode mode;
@property (assign, nonatomic) NSUInteger style;
@property (assign, nonatomic) MPFoldStyle foldStyle;
@property (assign, nonatomic) MPFlipStyle flipStyle;
@property (readonly, nonatomic) BOOL isFold;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *modeSegment;

- (IBAction)stepperValueChanged:(id)sender;
- (IBAction)stylePressed:(UIBarButtonItem *)sender;
- (IBAction)infoPressed:(id)sender;
- (IBAction)modeValueChanged:(id)sender;
- (IBAction)detailPressed:(id)sender;

@end
