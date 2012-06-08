//
//  MPTransition.m
//  MPFoldTransition (v1.1.4)
//
//  Created by Mark Pospesel on 5/14/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#define DEFAULT_DURATION 0.3

#import "MPTransition.h"
#import <QuartzCore/QuartzCore.h>
@implementation MPTransition

@synthesize sourceView = _sourceView;
@synthesize destinationView = _destinationView;
@synthesize duration = _duration;
@synthesize rect = _rect;
@synthesize completionAction = _completionAction;
@synthesize timingCurve = _timingCurve;
@synthesize dismissing = _dismissing;
@synthesize m34 = _m34;

- (id)initWithSourceView:(UIView *)sourceView destinationView:(UIView *)destinationView duration:(NSTimeInterval)duration timingCurve:(UIViewAnimationCurve)timingCurve completionAction:(MPTransitionAction)action {
	self = [super init];
	if (self)
	{
		_sourceView = sourceView;
		_destinationView = destinationView;
		_duration = duration;
		_rect = [sourceView bounds];
		_timingCurve = timingCurve;
		_completionAction = action;
		_m34 = INFINITY;
	}
	
	return self;
}

#pragma mark - Instance methods

- (NSString *)timingCurveFunctionName
{
	switch ([self timingCurve]) {
		case UIViewAnimationCurveEaseOut:
			return kCAMediaTimingFunctionEaseOut;
			
		case UIViewAnimationCurveEaseIn:
			return kCAMediaTimingFunctionEaseIn;
			
		case UIViewAnimationCurveEaseInOut:
			return kCAMediaTimingFunctionEaseInEaseOut;
			
		case UIViewAnimationCurveLinear:
			return kCAMediaTimingFunctionLinear;
	}
	
	return kCAMediaTimingFunctionDefault;
}

- (void)perform
{
	[self perform:nil];
}

- (void)perform:(void (^)(BOOL finished))completion
{
	[NSException raise:@"Incomplete Implementation" format:@"MPTransition must be subclassed and the perform: method implemented."];
}

- (void)transitionDidComplete
{
	switch (self.completionAction) {
		case MPTransitionActionAddRemove:
			[[self.sourceView superview] addSubview:self.destinationView];
			[self.sourceView removeFromSuperview];
			[self.sourceView setHidden:NO];
			break;
			
		case MPTransitionActionShowHide:
			[self.destinationView setHidden:NO];
			[self.sourceView setHidden:YES];
			break;
			
		case MPTransitionActionNone:
			[self.sourceView setHidden:NO];
			break;
	}
}

- (void)setPresentingController:(UIViewController *)presentingController
{
    UIViewController *src = (UIViewController *)presentingController;
	// find out the presentation context for the presenting view controller
	while (YES)// (![src definesPresentationContext])
	{
		if (![src parentViewController])
			break;
		
		src = [src parentViewController];
	}

	[self setSourceView:src.view];
	if ([src wantsFullScreenLayout])
	{
		// don't include the status bar height in the rect to fold
		CGRect frame = src.view.frame;
		CGRect frameViewRect = [src.view convertRect:frame fromView:nil];
		CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
		CGRect statusBarWindowRect = [src.view.window convertRect:statusBarFrame fromWindow: nil];
		CGRect statusBarViewRect = [src.view convertRect:statusBarWindowRect fromView: nil];			
		frameViewRect.origin.y += statusBarViewRect.size.height;
		frameViewRect.size.height -= statusBarViewRect.size.height;
		[self setRect:frameViewRect];
	}
}

#pragma mark - Class methods

+ (NSTimeInterval)defaultDuration
{
	return DEFAULT_DURATION;
}

@end

#pragma mark - UIView extensions

@implementation UIView(MPAnimation)

+ (BOOL)subView:(UIView *)subView1 isAboveSubView:(UIView *)subView2
{
	UIView *superview = [subView1 superview];
	int index1 = [[superview subviews] indexOfObject:subView1];
	int index2 = [[superview subviews] indexOfObject:subView2];
	if (index2 == NSNotFound)
		[NSException raise:@"Invalid Operation" format:@"Both views must have the same superview"];
	return index1 > index2;
}

+ (BOOL)subView:(UIView *)subView1 isBelowSubView:(UIView *)subView2
{
	return [self subView:subView2 isAboveSubView:subView1];
}

- (BOOL)isAboveSiblingView:(UIView *)siblingView
{
	return [UIView subView:self isAboveSubView:siblingView];
}

- (BOOL)isBelowSiblingView:(UIView *)siblingView
{
	return [UIView subView:siblingView isAboveSubView:self];
}

@end
