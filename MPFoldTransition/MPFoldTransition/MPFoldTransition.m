//
//  MPFoldTransition.m
//  MPFoldTransition (v 1.0.0)
//
//  Created by Mark Pospesel on 4/4/12.
//  Copyright (c) 2012 Odyssey Computing. All rights reserved.
//

#define DEFAULT_DURATION 0.3

#import "MPFoldTransition.h"
#import "MPAnimation.h"
#import <QuartzCore/QuartzCore.h>
#include <math.h>

static inline double mp_radians (double degrees) {return degrees * M_PI/180;}

@interface MPFoldTransition()

@property (assign, nonatomic, getter = isDimissing) BOOL dismissing;

@end

@implementation MPFoldTransition

@synthesize sourceView = _sourceView;
@synthesize destinationView = _destinationView;
@synthesize duration = _duration;
@synthesize rect = _rect;
@synthesize style = _style;
@synthesize completionAction = _completionAction;
@synthesize timingCurve = _timingCurve;

@synthesize dismissing = _dismissing;

- (id)initWithSourceView:(UIView *)sourceView destinationView:(UIView *)destinationView duration:(NSTimeInterval)duration style:(MPFoldStyle)style completionAction:(MPTransitionAction)action {
	self = [super init];
	if (self)
	{
		_sourceView = sourceView;
		_destinationView = destinationView;
		_duration = duration;
		_style = style;
		_rect = [sourceView bounds];
		_completionAction = action;
		if ((style & MPFoldStyleUnfold) == MPFoldStyleUnfold)
			_timingCurve = UIViewAnimationCurveEaseIn;
		else 
			_timingCurve = UIViewAnimationCurveEaseOut;
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
	BOOL forwards = ([self style] & MPFoldStyleUnfold) != MPFoldStyleUnfold;
	BOOL vertical = ([self style] & MPFoldStyleHorizontal) != MPFoldStyleHorizontal;
	BOOL cubic = ([self style] & MPFoldStyleCubic) == MPFoldStyleCubic;
	
	CGRect bounds = self.rect;
	CGFloat scale = [[UIScreen mainScreen] scale];
	
	// we inset the folding panels 1 point on each side with a transparent margin to antialiase the edges
	UIEdgeInsets foldInsets = vertical? UIEdgeInsetsMake(0, 1, 0, 1) : UIEdgeInsetsMake(1, 0, 1, 0);
	// for cubic fold, we do the same for the sliding panels 
	UIEdgeInsets slideInsets = cubic? foldInsets : UIEdgeInsetsZero;
	CGFloat slideInsetWidth = cubic? 2 : 0;
	
	CGRect upperRect = bounds;
	if (vertical)
		upperRect.size.height = bounds.size.height / 2;
	else
		upperRect.size.width = bounds.size.width / 2;
	CGRect lowerRect = upperRect;
	BOOL isOddSize = vertical? (upperRect.size.height != (roundf(upperRect.size.height * scale)/scale)) : (upperRect.size.width != (roundf(upperRect.size.width * scale) / scale));
	if (isOddSize)
	{
		// If view has an odd height, make the 2 panels of integer height with top panel 1 pixel taller (see below)
		if (vertical)
		{
			upperRect.size.height = (roundf(upperRect.size.height * scale)/scale);
			lowerRect.size.height = bounds.size.height - upperRect.size.height;
		}
		else 
		{
			upperRect.size.width = (roundf(upperRect.size.width * scale)/scale);
			lowerRect.size.width = bounds.size.width - upperRect.size.width;
		}
	}
	if (vertical)
		lowerRect.origin.y += upperRect.size.height;
	else
		lowerRect.origin.x += upperRect.size.width;
		
	if (![self isDimissing])
		self.destinationView.bounds = (CGRect){CGPointZero, bounds.size};
	
	CGRect destUpperRect = CGRectOffset(upperRect, -upperRect.origin.x, -upperRect.origin.y);
	CGRect destLowerRect = CGRectOffset(lowerRect, -upperRect.origin.x, -upperRect.origin.y);
	
	if ([self isDimissing])
	{
		CGFloat x = self.destinationView.bounds.size.width - bounds.size.width;
		CGFloat y = self.destinationView.bounds.size.height - bounds.size.height;
		destUpperRect.origin.x += x;
		destLowerRect.origin.x += x;
		destUpperRect.origin.y += y;
		destLowerRect.origin.y += y;
		[self setRect:CGRectOffset([self rect], x, y)];
	}
	
	// Create 4 images to represent 2 halves of the 2 views
	UIImage * foldUpper = [MPAnimation renderImageFromView:forwards? self.sourceView : self.destinationView withRect:forwards? upperRect : destUpperRect transparentInsets:foldInsets];
	UIImage * foldLower = [MPAnimation renderImageFromView:forwards? self.sourceView : self.destinationView withRect:forwards? lowerRect : destLowerRect transparentInsets:foldInsets];
	if (isOddSize)
	{
		// ... except the bottom sleeve should also be 1 pixel taller (and moved up 1 to overlap 1 pixel with top sleeve)
		if (vertical)
		{
			lowerRect.size.height += 1;
			lowerRect.origin.y -= 1;
			destLowerRect.size.height += 1;
			destLowerRect.origin.y -= 1;
		}
		else
		{
			lowerRect.size.width += 1;
			lowerRect.origin.x -= 1;
			destLowerRect.size.width += 1;
			destLowerRect.origin.x -= 1;			
		}
	}
	UIImage *slideUpper = [MPAnimation renderImageFromView:forwards? self.destinationView : self.sourceView withRect:forwards? destUpperRect : upperRect transparentInsets:slideInsets];
	UIImage *slideLower = [MPAnimation renderImageFromView:forwards? self.destinationView : self.sourceView withRect:forwards? destLowerRect : lowerRect transparentInsets:slideInsets];
		
	UIView *actingSource = [self sourceView]; // the view that is already part of the view hierarchy
	UIView *containerView = [actingSource superview];
	if (!containerView)
	{
		// in case of dismissal, it is actually the destination view since we had to add it
		// in order to get it to render correctly
		actingSource = [self destinationView];
		containerView = [actingSource superview];
	}
	[actingSource setHidden:YES];
	
	CATransform3D transform = CATransform3DIdentity;
	CALayer *topSleeve;
	CALayer *upperFold;
	CALayer *lowerFold;
	CALayer *bottomSleeve;
	CALayer *topSleeveShadow;
	CALayer *upperFoldShadow;
	CALayer *lowerFoldShadow;
	CALayer *bottomSleeveShadow;
	UIView *mainView;
	CGFloat width = vertical? bounds.size.width : bounds.size.height;
	CGFloat height = vertical? bounds.size.height/2 : bounds.size.width/2;
	CGFloat upperHeight = roundf(height * scale) / scale; // round heights to integer for odd height
	CGFloat lowerHeight = (height * 2) - upperHeight;
	CALayer *firstJointLayer;
	CALayer *secondJointLayer;
	CALayer *perspectiveLayer;
	
	// view to hold all our sublayers
	CGRect mainRect = [containerView convertRect:self.rect fromView:actingSource];
	CGPoint center = (CGPoint){CGRectGetMidX(mainRect), CGRectGetMidY(mainRect)};
	if ([containerView isKindOfClass:[UIWindow class]])
		mainRect = [actingSource convertRect:mainRect fromView:nil];
	mainView = [[UIView alloc] initWithFrame:mainRect];
	mainView.backgroundColor = [UIColor clearColor];
	mainView.transform = actingSource.transform;
	[containerView insertSubview:mainView atIndex:0];
	if ([containerView isKindOfClass:[UIWindow class]])
	{
		[mainView.layer setPosition:center];
	}
	
	// layer that covers the 2 folding panels in the middle
	perspectiveLayer = [CALayer layer];
	perspectiveLayer.frame = CGRectMake(0, 0, vertical? width : height * 2, vertical? height * 2 : width);
	[mainView.layer addSublayer:perspectiveLayer];
	
	// layer that encapsulates the join between the top sleeve (remains flat) and upper folding panel
	firstJointLayer = [CATransformLayer layer];
	firstJointLayer.frame = mainView.bounds;
	[perspectiveLayer addSublayer:firstJointLayer];
	
	// This remains flat, and is the upper half of the destination view when moving forwards
	// It slides down to meet the bottom sleeve in the center
	topSleeve = [CALayer layer];
	topSleeve.frame = CGRectMake(0, 0, vertical? width + slideInsetWidth : upperHeight, vertical? upperHeight : width + slideInsetWidth);
	topSleeve.anchorPoint = CGPointMake(vertical? 0.5 : 1, vertical? 1 : 0.5);
	topSleeve.position = CGPointMake(vertical? width/2 : 0, vertical? 0 : width/2);
	[topSleeve setContents:(id)[slideUpper CGImage]];
	[firstJointLayer addSublayer:topSleeve];
	
	// This piece folds away from user along top edge, and is the upper half of the source view when moving forwards
	upperFold = [CALayer layer];
	upperFold.frame = CGRectMake(0, 0, vertical? width + 2 : upperHeight, vertical? upperHeight : width + 2);
	upperFold.anchorPoint = CGPointMake(vertical? 0.5 : 0, vertical? 0 : 0.5);
	upperFold.position = CGPointMake(vertical? width/2 : 0, vertical? 0 : width / 2);
	upperFold.contents = (id)[foldUpper CGImage];
	[firstJointLayer addSublayer:upperFold];
	
	// layer that encapsultates the join between the upper and lower folding panels (the V in the fold)
	secondJointLayer = [CATransformLayer layer];
	secondJointLayer.frame = mainView.bounds;
	secondJointLayer.frame = CGRectMake(0, 0, vertical? width : height * 2, vertical? height*2 : width);
	secondJointLayer.anchorPoint = CGPointMake(vertical? 0.5 : 0, vertical? 0 : 0.5);
	secondJointLayer.position = CGPointMake(vertical? width/2 : upperHeight, vertical? upperHeight : width / 2);
	[firstJointLayer addSublayer:secondJointLayer];
	
	// This piece folds away from user along bottom edge, and is the lower half of the source view when moving forwards
	lowerFold = [CALayer layer];
	lowerFold.frame = CGRectMake(0, 0, vertical? width + 2 : lowerHeight, vertical? lowerHeight : width + 2);
	lowerFold.anchorPoint = CGPointMake(vertical? 0.5 : 0, vertical? 0 : 0.5);
	lowerFold.position = CGPointMake(vertical? width/2 : 0, vertical? 0 : width / 2);
	lowerFold.contents = (id)[foldLower CGImage];
	[secondJointLayer addSublayer:lowerFold];
	
	// This remains flat, and is the lower half of the destination view when moving forwards
	// It slides up to meet the top sleeve in the center
	bottomSleeve = [CALayer layer];
	bottomSleeve.frame = CGRectMake(0, 0, vertical? width + slideInsetWidth : upperHeight, vertical? upperHeight : width + slideInsetWidth); // bottom sleeve for odd height is rounded up
	bottomSleeve.anchorPoint = CGPointMake(vertical? 0.5 : 0, vertical? 0 : 0.5);
	bottomSleeve.position = CGPointMake(vertical? width/2 : lowerHeight, vertical? lowerHeight : width / 2);
	[bottomSleeve setContents:(id)[slideLower CGImage]];
	[secondJointLayer addSublayer:bottomSleeve];
	
	firstJointLayer.anchorPoint = CGPointMake(vertical? 0.5 : 0, vertical? 0 : 0.5);
	firstJointLayer.position = CGPointMake(vertical? width/2 : 0, vertical? 0 : width / 2);
	
	// Shadow layers to add shadowing to the 2 folding panels
	upperFoldShadow = [CALayer layer];
	[upperFold addSublayer:upperFoldShadow];
	upperFoldShadow.frame = CGRectInset(upperFold.bounds, foldInsets.left, foldInsets.top);
	upperFoldShadow.backgroundColor = [UIColor blackColor].CGColor;
	upperFoldShadow.opacity = 0;
	
	lowerFoldShadow = [CALayer layer];
	[lowerFold addSublayer:lowerFoldShadow];
	lowerFoldShadow.frame = CGRectInset(lowerFold.bounds, foldInsets.left, foldInsets.top);
	lowerFoldShadow.backgroundColor = [UIColor blackColor].CGColor;
	lowerFoldShadow.opacity = 0;
	
	if (cubic)
	{
		// add shadow layers to top and bottom sleeves as well
		topSleeveShadow = [CALayer layer];
		[topSleeve addSublayer:topSleeveShadow];
		topSleeveShadow.frame = CGRectInset(topSleeve.bounds, slideInsets.left, slideInsets.top);
		topSleeveShadow.backgroundColor = [UIColor blackColor].CGColor;
		topSleeveShadow.opacity = 0;
		
		bottomSleeveShadow = [CALayer layer];
		[bottomSleeve addSublayer:bottomSleeveShadow];
		bottomSleeveShadow.frame = CGRectInset(bottomSleeve.bounds, slideInsets.left, slideInsets.top);
		bottomSleeveShadow.backgroundColor = [UIColor blackColor].CGColor;
		bottomSleeveShadow.opacity = 0;
	}
	
	NSUInteger frameCount = ceilf(self.duration * 60); // we want 60 FPS
	
	// Perspective is best proportional to the height of the pieces being folded away, rather than a fixed value
	// the larger the piece being folded, the more perspective distance (zDistance) is needed.
	// m34 = -1/zDistance
	transform.m34 = -1.0/(height * 4.6666667);
	perspectiveLayer.sublayerTransform = transform;
	
	// Create a transaction (to group our animations with a single callback when done)
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:self.duration] forKey:kCATransactionAnimationDuration];
	[CATransaction setValue:[CAMediaTimingFunction functionWithName:[self timingCurveFunctionName]] forKey:kCATransactionAnimationTimingFunction];
	[CATransaction setCompletionBlock:^{
		[mainView removeFromSuperview];
		[self transitionDidComplete];
		if (completion)
			completion(YES); // execute the completion block that was passed in
	}];
	
	NSString *rotationKey = vertical? @"transform.rotation.x" : @"transform.rotation.y";
	double factor = (vertical? 1 : - 1) * M_PI / 180;
	// fold the first (top) joint away from us
	CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:rotationKey];
	[animation setFromValue:forwards? [NSNumber numberWithDouble:0] : [NSNumber numberWithDouble:-90*factor]];
	[animation setToValue:forwards? [NSNumber numberWithDouble:-90*factor] : [NSNumber numberWithDouble:0]];
	[animation setFillMode:kCAFillModeForwards];
	[animation setRemovedOnCompletion:NO];
	[firstJointLayer addAnimation:animation forKey:nil];
	
	// fold the second joint back towards us at twice the angle (since it's connected to the first fold we're folding away)
	animation = [CABasicAnimation animationWithKeyPath:rotationKey];
	[animation setFromValue:forwards? [NSNumber numberWithDouble:0] : [NSNumber numberWithDouble:180*factor]];
	[animation setToValue:forwards? [NSNumber numberWithDouble:180*factor] : [NSNumber numberWithDouble:0]];
	[animation setFillMode:kCAFillModeForwards];
	[animation setRemovedOnCompletion:NO];
	[secondJointLayer addAnimation:animation forKey:nil];
	
	if (cubic)
	{
		// for cubic animation, bottom and top-sleeves remain at fixed 90 degree angles to lower and upper folds, respectively
		[bottomSleeve setTransform:CATransform3DRotate([bottomSleeve transform], -90*factor, vertical? 1 : 0, vertical? 0 : 1, 0)];
		[topSleeve setTransform:CATransform3DRotate([topSleeve transform], 90*factor, vertical? 1 : 0, vertical? 0 : 1, 0)];
	}
	else
	{
		// fold the bottom sleeve (3rd joint) away from us, so that net result is it lays flat from user's perspective
		animation = [CABasicAnimation animationWithKeyPath:rotationKey];
		[animation setFromValue:forwards? [NSNumber numberWithDouble:0] : [NSNumber numberWithDouble:-90*factor]];
		[animation setToValue:forwards? [NSNumber numberWithDouble:-90*factor] : [NSNumber numberWithDouble:0]];
		[animation setFillMode:kCAFillModeForwards];
		[animation setRemovedOnCompletion:NO];
		[bottomSleeve addAnimation:animation forKey:nil];
		
		// fold top sleeve towards us, so that net result is it lays flat from user's perspective
		animation = [CABasicAnimation animationWithKeyPath:rotationKey];
		[animation setFromValue:forwards? [NSNumber numberWithDouble:0] : [NSNumber numberWithDouble:90*factor]];
		[animation setToValue:forwards? [NSNumber numberWithDouble:90*factor] : [NSNumber numberWithDouble:0]];
		[animation setFillMode:kCAFillModeForwards];
		[animation setRemovedOnCompletion:NO];
		[topSleeve addAnimation:animation forKey:nil];
	}
	
	// Build an array of keyframes for perspectiveLayer.bounds.size.height
	NSMutableArray* arrayHeight = [NSMutableArray arrayWithCapacity:frameCount + 1];
	CGFloat progress;
	CGFloat cosHeight;
	for (int frame = 0; frame <= frameCount; frame++)
	{
		progress = (((float)frame) / frameCount);
		cosHeight = ((forwards? cos(mp_radians(90 * progress)) : sin(mp_radians(90 * progress)))* 2*height); // range from 2*height to 0 along a cosine curve
		if ((forwards && frame == frameCount) || (!forwards && frame == 0))
			cosHeight = 0;
		[arrayHeight addObject:[NSNumber numberWithFloat:cosHeight]];
	}
	
	// resize height of the 2 folding panels along a cosine curve.  This is necessary to maintain the 2nd joint in the center
	// Since there's no built-in sine timing curve, we'll use CAKeyframeAnimation to achieve it
	CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animationWithKeyPath:vertical? @"bounds.size.height" : @"bounds.size.width"];
	[keyAnimation setValues:[NSArray arrayWithArray:arrayHeight]];
	[keyAnimation setFillMode:kCAFillModeForwards];
	[keyAnimation setRemovedOnCompletion:NO];
	[perspectiveLayer addAnimation:keyAnimation forKey:nil];
	
	// Dim the 2 folding panels as they fold away from us
	// Note that 2 slightly different endpoint opacities are used to help distinguish the upper and lower panels
	animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	[animation setFromValue:forwards? [NSNumber numberWithDouble:0] : [NSNumber numberWithDouble:0.5]];
	[animation setToValue:forwards? [NSNumber numberWithDouble:0.5] : [NSNumber numberWithDouble:0]];
	[animation setFillMode:kCAFillModeForwards];
	[animation setRemovedOnCompletion:NO];
	[upperFoldShadow addAnimation:animation forKey:nil];
	
	animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	[animation setFromValue:forwards? [NSNumber numberWithDouble:0] : [NSNumber numberWithDouble:0.45]];
	[animation setToValue:forwards? [NSNumber numberWithDouble:0.45] : [NSNumber numberWithDouble:0]]; // use slightly different opacities for the 2 halves
	[animation setFillMode:kCAFillModeForwards];
	[animation setRemovedOnCompletion:NO];
	[lowerFoldShadow addAnimation:animation forKey:nil];
	
	if (cubic)
	{
		animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
		[animation setFromValue:forwards? [NSNumber numberWithDouble:0.5] : [NSNumber numberWithDouble:0]];
		[animation setToValue:forwards? [NSNumber numberWithDouble:0] : [NSNumber numberWithDouble:0.5]];
		[animation setFillMode:kCAFillModeForwards];
		[animation setRemovedOnCompletion:NO];
		[topSleeveShadow addAnimation:animation forKey:nil];
		
		animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
		[animation setFromValue:forwards? [NSNumber numberWithDouble:0.5] : [NSNumber numberWithDouble:0]];
		[animation setToValue:forwards? [NSNumber numberWithDouble:0] : [NSNumber numberWithDouble:0.5]];
		[animation setFillMode:kCAFillModeForwards];
		[animation setRemovedOnCompletion:NO];
		[bottomSleeveShadow addAnimation:animation forKey:nil];
	}
	
	// Commit the transaction
	[CATransaction commit];
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

#pragma mark - Class methods

+ (NSTimeInterval)defaultDuration
{
	return DEFAULT_DURATION;
}

+ (void)transitionFromViewController:(UIViewController *)fromController toViewController:(UIViewController *)toController duration:(NSTimeInterval)duration style:(MPFoldStyle)style completion:(void (^)(BOOL finished))completion
{
	MPFoldTransition *foldTransition = [[MPFoldTransition alloc] initWithSourceView:fromController.view destinationView:toController.view duration:duration style:style completionAction:MPTransitionActionNone];
	[foldTransition perform:completion];
}

+ (void)transitionFromView:(UIView *)fromView toView:(UIView *)toView duration:(NSTimeInterval)duration style:(MPFoldStyle)style transitionAction:(MPTransitionAction)action completion:(void (^)(BOOL finished))completion
{
	MPFoldTransition *foldTransition = [[MPFoldTransition alloc] initWithSourceView:fromView destinationView:toView duration:duration style:style completionAction:action];
	[foldTransition perform:completion];
}

+ (void)presentViewController:(UIViewController *)viewControllerToPresent from:(UIViewController *)presentingController duration:(NSTimeInterval)duration style:(MPFoldStyle)style completion:(void (^)(BOOL finished))completion
{
    UIViewController *src = (UIViewController *)presentingController;
	// find out the presentation context for the presenting view controller
	while (YES)// (![src definesPresentationContext])
	{
		if (![src parentViewController])
			break;
		
		src = [src parentViewController];
	}
		
	MPFoldTransition *foldTransition = [[MPFoldTransition alloc] initWithSourceView:src.view destinationView:viewControllerToPresent.view duration:duration style:style completionAction:MPTransitionActionNone];
	
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
		[foldTransition setRect:frameViewRect];
	}
	
	[foldTransition perform:^(BOOL finished) {
		// under iPad for our fold transition, we need to be full screen modal (iPhone is always full screen modal)
		UIModalPresentationStyle oldStyle = [presentingController modalPresentationStyle];
		if (oldStyle != UIModalPresentationFullScreen && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
			[presentingController setModalPresentationStyle:UIModalPresentationFullScreen];
		
		[presentingController presentViewController:viewControllerToPresent animated:NO completion:^{
			// restore previous modal presentation style
			if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
				[presentingController setModalPresentationStyle:oldStyle];
		}];
		
		if (completion)
			completion(YES);
	}];
}

+ (void)dismissViewControllerFromPresentingController:(UIViewController *)presentingController duration:(NSTimeInterval)duration style:(MPFoldStyle)style completion:(void (^)(BOOL finished))completion
{
	UIViewController *src = [presentingController presentedViewController];
	if (!src)
		[NSException raise:@"Invalid Operation" format:@"dismissViewControllerFromPresentingController:direction:completion: can only be performed on a view controller with a presentedViewController."];
	
    UIViewController *dest = (UIViewController *)presentingController;
	
	// find out the presentation context for the presenting view controller
	while (YES)// (![src definesPresentationContext])
	{
		if (![dest parentViewController])
			break;
		
		dest = [dest parentViewController];
	}
	
	MPFoldTransition *foldTransition = [[MPFoldTransition alloc] initWithSourceView:src.view destinationView:dest.view duration:duration style:style completionAction:MPTransitionActionNone];
	[foldTransition setDismissing:YES];
	[presentingController dismissViewControllerAnimated:NO completion:nil];
	[foldTransition perform:^(BOOL finished) {
		[dest.view setHidden:NO];
		if (completion)
			completion(YES);
	}];
}

@end

#pragma mark - UIViewController(MPFoldTransition)

@implementation UIViewController(MPFoldTransition)

- (void)presentViewController:(UIViewController *)viewControllerToPresent foldStyle:(MPFoldStyle)style completion:(void (^)(BOOL finished))completion
{
	[MPFoldTransition presentViewController:viewControllerToPresent from:self duration:[MPFoldTransition defaultDuration] style:style completion:completion];
}

- (void)dismissViewControllerWithFoldStyle:(MPFoldStyle)style completion:(void (^)(BOOL finished))completion
{
	[MPFoldTransition dismissViewControllerFromPresentingController:self duration:[MPFoldTransition defaultDuration] style:style completion:completion];
}

@end

#pragma mark - UINavigationController(MPFoldTransition)

@implementation UINavigationController(MPFoldTransition)

//- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
- (void)pushViewController:(UIViewController *)viewController foldStyle:(MPFoldStyle)style
{
	[MPFoldTransition transitionFromViewController:[self visibleViewController] 
								  toViewController:viewController 
										  duration:[MPFoldTransition defaultDuration]  
											 style:style 
										completion:^(BOOL finished) {
											[self pushViewController:viewController animated:NO];
										}
	 ];
}

- (UIViewController *)popViewControllerWithFoldStyle:(MPFoldStyle)style
{
	UIViewController *toController = [[self viewControllers] objectAtIndex:[[self viewControllers] count] - 2];

	[MPFoldTransition transitionFromViewController:[self visibleViewController] 
								  toViewController:toController 
										  duration:[MPFoldTransition defaultDuration] 
											 style:style
										completion:^(BOOL finished) {
											[self popViewControllerAnimated:NO];
										}
	 ];
	
	return toController;
}

@end
