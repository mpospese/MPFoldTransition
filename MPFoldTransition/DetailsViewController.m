//
//  DetailsViewController.m
//  MPFoldTransition (v 1.0.0)
//
//  Created by Mark Pospesel on 4/20/12.
//  Copyright (c) 2012 Odyssey Computing. All rights reserved.
//

#import "DetailsViewController.h"
#import "MPFoldSegue.h"

@interface DetailsViewController ()

@end

@implementation DetailsViewController

@synthesize style;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	[self.navigationItem setHidesBackButton:YES animated:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue isKindOfClass:[MPFoldSegue class]])
	{
		MPFoldSegue *foldSegue = (MPFoldSegue *)segue;
		// do the opposite fold style from the transition that presented this view
		[foldSegue setStyle:MPFoldStyleFlipFoldBit([self style])];
	}
}

@end
