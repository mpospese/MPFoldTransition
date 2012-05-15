//
//  StyleTable.m
//  MPTransition (v 1.1.0)
//
//  Created by Mark Pospesel on 5/1/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import "StyleTable.h"
#import "MPFoldTransition.h"
#import "MPFlipTransition.h"

@interface StyleTable ()

@end

@implementation StyleTable

@synthesize fold=_fold;
@synthesize style=_style;
@synthesize styleDelegate=_styleDelegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.navigationItem.hidesBackButton = YES;
	
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (CGSize)contentSizeForViewInPopover
{
	return CGSizeMake(240, (6 * [self.tableView rowHeight]) + (3 * [self.tableView sectionHeaderHeight]));
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	// row = whether bit flag is on/off
	int row = [indexPath row];
	// section = which bit flag
	int section = [indexPath section];
	if (row == (([self style] & (1 << section)) >> section))
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// row = whether bit flag is on/off
	int row = [indexPath row];
	// section = which bit flag
	int section = [indexPath section];
	if (row != (([self style] & (1 << section)) >> section))
	{
		UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(([self style] & (1 << section)) >> section) inSection:section]];
		[oldCell setAccessoryType:UITableViewCellAccessoryNone];
		
		UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
		[newCell setAccessoryType:UITableViewCellAccessoryCheckmark];
	}
	
	NSUInteger newStyle = ([self style] & ~(1 << section)) | (row << section);
	[self setStyle:newStyle];
	[[self styleDelegate] styleDidChange:self.style];
}

- (IBAction)donePressed:(id)sender {
	if ([self isFold])
	{
		// use the opposite fold style from the selected style
		MPFoldStyle popStyle = MPFoldStyleFlipFoldBit([self style]);
		
		[self.navigationController popViewControllerWithFoldStyle:popStyle];
	}
	else 
	{
		// use the opposite flip style from the selected style
		MPFlipStyle popStyle = MPFlipStyleFlipDirectionBit([self style]);
		
		[self.navigationController popViewControllerWithFlipStyle:popStyle];
	}
}

@end
