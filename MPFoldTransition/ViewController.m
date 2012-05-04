//
//  ViewController.m
//  MPFoldTransition (v 1.0.0)
//
//  Created by Mark Pospesel on 4/20/12.
//  Copyright (c) 2012 Odyssey Computing. All rights reserved.
//

#import "ViewController.h"
#import "MPFoldTransition.h"
#import "AppDelegate.h"
#import "MPFoldSegue.h"
#import "DetailsViewController.h"

#define ABOUT_IDENTIFIER		@"AboutID"
#define ABOUT_SEGUE_IDENTIFIER		@"segueToAbout"
#define DETAILS_SEGUE_IDENTIFIER	@"segueToDetails"
#define STYLE_TABLE_IDENTIFIER	@"StyleTableID"

@interface ViewController ()

@property (strong, nonatomic) UIPopoverController *popover;

@end

@implementation ViewController

@synthesize style = _style;
@synthesize contentView = _contentView;
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
	_style = MPFoldStyleCubic;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	[self.contentView addSubview:[self getLabelForIndex:0]];
}

- (void)viewDidUnload
{
    [self setContentView:nil];
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

- (UILabel *)getLabelForIndex:(NSUInteger)index
{
	UILabel *label = [[UILabel alloc] initWithFrame:self.contentView.bounds];
	label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[label setFont:[UIFont boldSystemFontOfSize:84]];
	[label setTextAlignment:UITextAlignmentCenter];
	[label setTextColor:[UIColor lightTextColor]];
	label.text = [NSString stringWithFormat:@"%d", index + 1];
	label.tag = index;
	
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
	
	return label;
}

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
	[MPFoldTransition transitionFromView:previousView 
								  toView:nextView 
								duration:[MPFoldTransition defaultDuration]
								   style:forwards? [self style]	: MPFoldStyleFlipFoldBit([self style]) 
						transitionAction:MPTransitionActionAddRemove
							  completion:^(BOOL finished) {
								  [stepper setUserInteractionEnabled:YES];
							  }
	 ];
}

/*	Info button is wired to use a storyboard segue, 
	but if you wanted to remove the segue and do it in code
	this is how you would do it
- (IBAction)infoPressed:(UIBarButtonItem *)sender {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[AppDelegate storyboardName] bundle:nil];
	AboutViewController *about = [storyboard instantiateViewControllerWithIdentifier:ABOUT_IDENTIFIER];
	[about setModalDelegate:self];

	[self presentViewController:about foldStyle:[self style] completion:nil];
}*/

- (IBAction)stylePressed:(id)sender {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	{
		// for iPhone push Style table onto navigation stack (using a fold transition in our current style!)
		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[AppDelegate storyboardName] bundle:nil];
		StyleTable *styleTable = [storyboard instantiateViewControllerWithIdentifier:STYLE_TABLE_IDENTIFIER];
		[styleTable setStyle:[self style]];
		[styleTable setStyleDelegate:self];
		
		[self.navigationController pushViewController:styleTable foldStyle:[self style]];
	}
	else
	{
		// for iPad present Style table as a popover
		if ([self.popover isPopoverVisible])
		{
			[self.popover dismissPopoverAnimated:YES];
			[self setPopover:nil];
			return;
		}
		
		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[AppDelegate storyboardName] bundle:nil];
		StyleTable *styleTable = [storyboard instantiateViewControllerWithIdentifier:STYLE_TABLE_IDENTIFIER];
		[styleTable setStyle:[self style]];
		[styleTable setStyleDelegate:self];
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:styleTable];
		[self setPopover:[[UIPopoverController alloc] initWithContentViewController:navController]];
		
		[self.popover setDelegate:self];
		[self.popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];		
	}
}

#pragma mark - Storyboards

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	// set the selected fold style to our segues
	if ([[segue identifier] isEqualToString:DETAILS_SEGUE_IDENTIFIER])
	{
		DetailsViewController *details = [segue destinationViewController];
		[details setStyle:[self style]];
		
		MPFoldSegue *foldSegue = (MPFoldSegue *)segue;
		[foldSegue setStyle:[self style]];
	}
	else if ([[segue identifier] isEqualToString:ABOUT_SEGUE_IDENTIFIER])
	{
		AboutViewController *about = [segue destinationViewController];
		[about setModalDelegate:self];
		
		MPFoldSegue *foldSegue = (MPFoldSegue *)segue;
		[foldSegue setStyle:[self style]];
	}
}

#pragma mark - MPModalViewControllerDelegate

- (void)dismiss
{
	// use the opposite fold style from the transition that presented the modal view
	MPFoldStyle dismissStyle = MPFoldStyleFlipFoldBit([self style]);
	
	[self dismissViewControllerWithFoldStyle:dismissStyle completion:nil];
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	[self setPopover:nil];
}

#pragma mark - StyleDelegate

- (void)styleDidChange:(MPFoldStyle)newStyle
{
	[self setStyle:newStyle];
	
	// We want clipsToBounds == YES on the central contentView when mode bit is not cubic
	// Otherwise you see the top & bottom panels sliding out and looks weird
	[self.contentView setClipsToBounds:((newStyle & MPFoldStyleCubic) != MPFoldStyleCubic)];
}

@end
