//
//  ViewController.m
//  MPTransition (v 1.1.4)
//
//  Created by Mark Pospesel on 4/20/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import "ViewController.h"
#import "MPFoldTransition.h"
#import "MPFlipTransition.h"
#import "AppDelegate.h"
#import "MPFoldSegue.h"
#import "DetailsViewController.h"
#import <QuartzCore/QuartzCore.h>

#define ABOUT_IDENTIFIER		@"AboutID"
#define DETAILS_IDENTIFIER		@"DetailsID"
#define ABOUT_SEGUE_IDENTIFIER		@"segueToAbout"
#define DETAILS_SEGUE_IDENTIFIER	@"segueToDetails"
#define STYLE_TABLE_IDENTIFIER	@"StyleTableID"
#define FOLD_STYLE_TABLE_IDENTIFIER	@"FoldStyleTableID"
#define FLIP_STYLE_TABLE_IDENTIFIER	@"FlipStyleTableID"

@interface ViewController ()

@property (strong, nonatomic) UIPopoverController *popover;

@end

@implementation ViewController

@synthesize mode = _mode;
@synthesize foldStyle = _foldStyle;
@synthesize flipStyle = _flipStyle;
@synthesize contentView = _contentView;
@synthesize modeSegment = _modeSegment;
@synthesize popover = _popover;

- (id)init
{
	self = [super init];
	if (self)
	{
		[self doInit];
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		[self doInit];
	}
	
	return self;
	
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self)
	{
		[self doInit];
	}
	
	return self;
	
}

- (void)doInit
{
	_mode = MPTransitionModeFold;
	_foldStyle = MPFoldStyleCubic;
	_flipStyle = MPFlipStyleDefault;
}

#pragma mark - Properties

- (NSUInteger)style
{
	switch ([self mode]) {
		case MPTransitionModeFold:
			return [self foldStyle];
			
		case MPTransitionModeFlip:
			return [self flipStyle];
	}
}

- (void)setStyle:(NSUInteger)style
{
	switch ([self mode]) {
		case MPTransitionModeFold:
			[self setFoldStyle:style];
			break;
			
		case MPTransitionModeFlip:
			[self setFlipStyle:style];
			break;
	}
}

- (BOOL)isFold
{
	return [self mode] == MPTransitionModeFold;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self.modeSegment setSelectedSegmentIndex:(int)[self mode]];
	[self.contentView addSubview:[self getLabelForIndex:0]];
}

- (void)viewDidUnload
{
    [self setContentView:nil];
	[self setModeSegment:nil];
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

#pragma mark - Instance methods

- (UIView *)getLabelForIndex:(NSUInteger)index
{
	UIView *container = [[UIView alloc] initWithFrame:self.contentView.bounds];
	container.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[container setBackgroundColor:[UIColor whiteColor]];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectInset(container.bounds, 10, 10)];
	label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[label setFont:[UIFont boldSystemFontOfSize:84]];
	[label setTextAlignment:UITextAlignmentCenter];
	[label setTextColor:[UIColor lightTextColor]];
	label.text = [NSString stringWithFormat:@"%d", index + 1];
	
	switch (index % 6) {
		case 0:
			[label setBackgroundColor:[UIColor redColor]];
			break;
			
		case 1:
			[label setBackgroundColor:[UIColor orangeColor]];
			break;
			
		case 2:
			[label setBackgroundColor:[UIColor yellowColor]];
			[label setTextColor:[UIColor darkTextColor]];
			break;
			
		case 3:
			[label setBackgroundColor:[UIColor greenColor]];
			[label setTextColor:[UIColor darkTextColor]];
			break;
			
		case 4:
			[label setBackgroundColor:[UIColor blueColor]];
			break;
			
		case 5:
			[label setBackgroundColor:[UIColor purpleColor]];
			break;
			
		default:
			break;
	}
	
	[container addSubview:label];
	container.tag = index;
	[container.layer setBorderColor:[[UIColor colorWithWhite:0.85 alpha:1] CGColor]];
	[container.layer setBorderWidth:2];
	
	return container;
}

- (void)updateClipsToBounds
{
	// We want clipsToBounds == YES on the central contentView when fold style mode bit is not cubic
	// Otherwise you see the top & bottom panels sliding out and looks weird
	[self.contentView setClipsToBounds:[self isFold] && (([self foldStyle] & MPFoldStyleCubic) != MPFoldStyleCubic)];	
}

#pragma mark - Touch handlers

- (IBAction)stepperValueChanged:(id)sender {
	UIStepper *stepper = sender;
	[stepper setUserInteractionEnabled:NO];
	UIView *previousView = [[self.contentView subviews] objectAtIndex:0];
	UIView *nextView = [self getLabelForIndex:stepper.value];
	BOOL forwards = nextView.tag > previousView.tag;
	// handle wrap around
	if (nextView.tag == stepper.maximumValue && previousView.tag == stepper.minimumValue)
		forwards = NO;
	else if (nextView.tag == stepper.minimumValue && previousView.tag == stepper.maximumValue)
		forwards = YES;
	
	// execute the transition
	if ([self isFold])
	{
		[MPFoldTransition transitionFromView:previousView 
									  toView:nextView 
									duration:[MPFoldTransition defaultDuration]
									   style:forwards? [self foldStyle]	: MPFoldStyleFlipFoldBit([self foldStyle]) 
							transitionAction:MPTransitionActionAddRemove
								  completion:^(BOOL finished) {
									  [stepper setUserInteractionEnabled:YES];
								  }
		 ];
	}
	else
	{
		[MPFlipTransition transitionFromView:previousView 
									  toView:nextView 
									duration:[MPTransition defaultDuration]
									   style:forwards? [self flipStyle]	: MPFlipStyleFlipDirectionBit([self flipStyle]) 
							transitionAction:MPTransitionActionAddRemove
								  completion:^(BOOL finished) {
									  [stepper setUserInteractionEnabled:YES];
								  }
		 ];
	}
}

- (IBAction)infoPressed:(UIBarButtonItem *)sender {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[AppDelegate storyboardName] bundle:nil];
	AboutViewController *about = [storyboard instantiateViewControllerWithIdentifier:ABOUT_IDENTIFIER];
	[about setModalDelegate:self];
	about.title = @"About";
	UIViewController *presented = about;
	
	/*int i = arc4random_uniform(3);
	switch (i) {
		case 1:
			// Embed in nav controller
			presented = [[UINavigationController alloc] initWithRootViewController:about];
			break;
			
		case 2:
		{
			// Embed in tab controller along with Details screen
			DetailsViewController *details = [storyboard instantiateViewControllerWithIdentifier:DETAILS_IDENTIFIER];
			[details setFold:[self isFold]];
			[details setStyle:[self style]];
			details.title = @"Details";
			UITabBarController *tab = [[UITabBarController alloc] init];
			[tab setViewControllers:[NSArray arrayWithObjects:about, details, nil] animated:NO];
			[tab setSelectedIndex:arc4random_uniform(2)];
			presented = tab;
		}
			break;
	}*/
	
	if ([self isFold])
		[self presentViewController:presented foldStyle:[self foldStyle] completion:nil];
	else
		[self presentViewController:presented flipStyle:[self flipStyle] completion:nil];
}

- (IBAction)stylePressed:(id)sender {
	BOOL isPad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
	// for iPad present Style table as a popover
	if (isPad && [self.popover isPopoverVisible])
	{
		[self.popover dismissPopoverAnimated:YES];
		[self setPopover:nil];
		return;
	}
	
	BOOL isFold = [self isFold];
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[AppDelegate storyboardName] bundle:nil];
	StyleTable *styleTable = [storyboard instantiateViewControllerWithIdentifier:isFold? FOLD_STYLE_TABLE_IDENTIFIER : FLIP_STYLE_TABLE_IDENTIFIER];
	[styleTable setFold:isFold];
	[styleTable setStyle:[self style]];
	[styleTable setStyleDelegate:self];

	if (!isPad)
	{
		// for iPhone push Style table onto navigation stack (using a fold transition in our current style!)
		if (isFold)
			[self.navigationController pushViewController:styleTable foldStyle:[self foldStyle]];
		else
			[self.navigationController pushViewController:styleTable flipStyle:[self flipStyle]];			
	}
	else
	{		
		// for iPad, just use a popover
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:styleTable];
		[self setPopover:[[UIPopoverController alloc] initWithContentViewController:navController]];
		
		[self.popover setDelegate:self];
		[self.popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];		
	}
}

- (IBAction)modeValueChanged:(id)sender {
	// switch between fold & flip transitions
	[self setMode:[sender selectedSegmentIndex]];
	[self updateClipsToBounds];
}

- (IBAction)detailPressed:(id)sender {
	BOOL isFold = [self isFold];
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[AppDelegate storyboardName] bundle:nil];
	DetailsViewController *details = [storyboard instantiateViewControllerWithIdentifier:DETAILS_IDENTIFIER];
	[details setFold:isFold];
	[details setStyle:[self style]];
	
	// push Details view controller onto navigation stack (using a fold or flip transition in our current style!)
	if (isFold)
		[self.navigationController pushViewController:details foldStyle:[self foldStyle]];
	else
		[self.navigationController pushViewController:details flipStyle:[self flipStyle]];	
}

#pragma mark - Storyboards

// I removed the segues from the storyboards so that I could switch between flip and fold segue classes
/*- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	// set the selected fold style to our segues
	if ([[segue identifier] isEqualToString:DETAILS_SEGUE_IDENTIFIER])
	{
		DetailsViewController *details = [segue destinationViewController];
		[details setStyle:[self foldStyle]];
		
		MPFoldSegue *foldSegue = (MPFoldSegue *)segue;
		[foldSegue setStyle:[self foldStyle]];
	}
	else if ([[segue identifier] isEqualToString:ABOUT_SEGUE_IDENTIFIER])
	{
		AboutViewController *about = [segue destinationViewController];
		[about setModalDelegate:self];
		
		MPFoldSegue *foldSegue = (MPFoldSegue *)segue;
		[foldSegue setStyle:[self foldStyle]];
	}
}*/

#pragma mark - MPModalViewControllerDelegate

- (void)dismiss
{
	// use the opposite fold style from the transition that presented the modal view
	if ([self isFold])
	{
		MPFoldStyle dismissStyle = MPFoldStyleFlipFoldBit([self foldStyle]);
		
		[self dismissViewControllerWithFoldStyle:dismissStyle completion:nil];
	}
	else
	{
		MPFlipStyle dismissStyle = MPFlipStyleFlipDirectionBit([self flipStyle]);
		[self dismissViewControllerWithFlipStyle:dismissStyle completion:nil];		
	}
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	[self setPopover:nil];
}

#pragma mark - StyleDelegate

- (void)styleDidChange:(NSUInteger)newStyle
{
	[self setStyle:newStyle];
	[self updateClipsToBounds];
}

@end
