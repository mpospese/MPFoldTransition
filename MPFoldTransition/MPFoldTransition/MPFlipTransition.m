//
//  MPFlipTransition.m
//  MPTransition (v1.1.3)
//
//  Created by Mark Pospesel on 5/15/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#define DEFAULT_COVERED_PAGE_SHADOW_OPACITY	(1./3)
#define DEFAULT_FLIPPING_PAGE_SHADOW_OPACITY 0.1

#import "MPFlipTransition.h"
#import "MPAnimation.h"
#import <QuartzCore/QuartzCore.h>
#include <math.h>

static inline double mp_radians (double degrees) {return degrees * M_PI/180;}

@interface MPFlipTransition()

@end

@implementation MPFlipTransition

#pragma mark - Properties

@synthesize style = _style;
@synthesize coveredPageShadowOpacity = _coveredPageShadowOpacity;
@synthesize flippingPageShadowOpacity = _flippingPageShadowOpacity;
@synthesize flipShadowColor = _flipShadowColor;

#pragma mark - init

- (id)initWithSourceView:(UIView *)sourceView destinationView:(UIView *)destinationView duration:(NSTimeInterval)duration style:(MPFlipStyle)style completionAction:(MPTransitionAction)action {
	self = [super initWithSourceView:sourceView destinationView:destinationView duration:duration timingCurve:UIViewAnimationCurveEaseInOut completionAction:action];
	if (self)
	{
		_style = style;	
		_coveredPageShadowOpacity = DEFAULT_COVERED_PAGE_SHADOW_OPACITY;
		_flippingPageShadowOpacity = DEFAULT_FLIPPING_PAGE_SHADOW_OPACITY;
		_flipShadowColor = [UIColor blackColor];
	}
	
	return self;
}

#pragma mark - Instance methods

// We split the animation into 2 parts, so don't ease out on the 1st half (we'll do that in 2nd half)
- (NSString *)timingCurveFunctionNameFirstHalf
{
	switch ([self timingCurve]) {
		case UIViewAnimationCurveEaseIn:
		case UIViewAnimationCurveEaseInOut:
			return kCAMediaTimingFunctionEaseIn;
			
		case UIViewAnimationCurveEaseOut:
		case UIViewAnimationCurveLinear:
			return kCAMediaTimingFunctionLinear;
	}
	
	return kCAMediaTimingFunctionEaseIn;
}

// We split the animation into 2 parts, so don't ease in on the 2nd half (we did that in the 1st half)
- (NSString *)timingCurveFunctionNameSecondHalf
{
	switch ([self timingCurve]) {
		case UIViewAnimationCurveEaseOut:
		case UIViewAnimationCurveEaseInOut:
			return kCAMediaTimingFunctionEaseOut;
			
		case UIViewAnimationCurveEaseIn:
		case UIViewAnimationCurveLinear:
			return kCAMediaTimingFunctionLinear;
	}
	
	return kCAMediaTimingFunctionEaseOut;
}

- (void)perform:(void (^)(BOOL finished))completion
{
	BOOL forwards = ([self style] & MPFlipStyleDirectionMask) != MPFlipStyleDirectionBackward;
	BOOL vertical = ([self style] & MPFlipStyleOrientationMask) == MPFlipStyleOrientationVertical;
	BOOL inward = ([self style] & MPFlipStylePerspectiveMask) == MPFlipStylePerspectiveReverse;
	
	CGRect bounds = self.rect;
	CGFloat scale = [[UIScreen mainScreen] scale];
	
	// we inset the panels 1 point on each side with a transparent margin to antialiase the edges
	UIEdgeInsets insets = vertical? UIEdgeInsetsMake(0, 1, 0, 1) : UIEdgeInsetsMake(1, 0, 1, 0);
	
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
	
	// The page flip animation is broken into 2 halves
	// 1. Flip old page up to vertical
	// 2. Flip new page from vertical down to flat
	// as we pass the halfway point of the animation, the "page" switches from old to new
	
	// front Page  = the half of current view we are flipping during 1st half
	// facing Page = the other half of the current view (doesn't move, gets covered by back page during 2nd half)
	// back Page   = the half of the next view that appears on the flipping page during 2nd half
	// reveal Page = the other half of the next view (doesn't move, gets revealed by front page during 1st half)
	UIImage *pageFrontImage = [MPAnimation renderImageFromView:self.sourceView withRect:forwards? lowerRect : upperRect transparentInsets:insets];
	// TODO: facing doesn't need insets
	UIImage *pageFacingImage = [MPAnimation renderImageFromView:self.sourceView withRect:forwards? upperRect : lowerRect];
		
	UIImage *pageBackImage = [MPAnimation renderImageFromView:self.destinationView withRect:forwards? destUpperRect : destLowerRect transparentInsets:insets];
	UIImage *pageRevealImage = [MPAnimation renderImageFromView:self.destinationView withRect:forwards? destLowerRect : destUpperRect];
	
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
	CALayer *pageFront;
	CALayer *pageBack;
	CALayer *pageFacing;
	CALayer *pageReveal;
	CAGradientLayer *pageFrontShadow;
	CAGradientLayer *pageBackShadow;
	CALayer *pageFacingShadow;
	CALayer *pageRevealShadow;
	
	UIView *mainView;
	CGFloat width = vertical? bounds.size.width : bounds.size.height;
	CGFloat height = vertical? bounds.size.height/2 : bounds.size.width/2;
	CGFloat upperHeight = roundf(height * scale) / scale; // round heights to integer for odd height
	
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
	
	pageReveal = [CALayer layer];
	pageReveal.frame = (CGRect){CGPointZero, pageRevealImage.size};
	pageReveal.anchorPoint = CGPointMake(vertical? 0.5 : forwards? 0 : 1, vertical? forwards? 0 : 1 : 0.5);
	pageReveal.position = CGPointMake(vertical? width/2 : upperHeight, vertical? upperHeight : width/2);
	[pageReveal setContents:(id)[pageRevealImage CGImage]];
	[mainView.layer addSublayer:pageReveal];
	
	pageFacing = [CALayer layer];
	pageFacing.frame = (CGRect){CGPointZero, pageFacingImage.size};
	pageFacing.anchorPoint = CGPointMake(vertical? 0.5 : forwards? 1 : 0, vertical? forwards? 1 : 0 : 0.5);
	pageFacing.position = CGPointMake(vertical? width/2 : upperHeight, vertical? upperHeight : width/2);
	[pageFacing setContents:(id)[pageFacingImage CGImage]];
	[mainView.layer addSublayer:pageFacing];
	
	pageFront = [CALayer layer];
	pageFront.frame = (CGRect){CGPointZero, pageFrontImage.size};
	pageFront.anchorPoint = CGPointMake(vertical? 0.5 : forwards? 0 : 1, vertical? forwards? 0 : 1 : 0.5);
	pageFront.position = CGPointMake(vertical? width/2 : upperHeight, vertical? upperHeight : width/2);
	[pageFront setContents:(id)[pageFrontImage CGImage]];
	[mainView.layer addSublayer:pageFront];
	
	pageBack = [CALayer layer];
	pageBack.frame = (CGRect){CGPointZero, pageBackImage.size};
	pageBack.anchorPoint = CGPointMake(vertical? 0.5 : forwards? 1 : 0, vertical? forwards? 1 : 0 : 0.5);
	pageBack.position = CGPointMake(vertical? width/2 : upperHeight, vertical? upperHeight : width/2);
	[pageBack setContents:(id)[pageBackImage CGImage]];
	
	// Create shadow layers
	pageFrontShadow = [CAGradientLayer layer];
	[pageFront addSublayer:pageFrontShadow];
	pageFrontShadow.frame = CGRectInset(pageFront.bounds, insets.left, insets.top);
	pageFrontShadow.opacity = 0.0;
	if (forwards)
		pageFrontShadow.colors = [NSArray arrayWithObjects:(id)[[[self flipShadowColor] colorWithAlphaComponent:0.5] CGColor], (id)[self flipShadowColor].CGColor, (id)[[UIColor clearColor] CGColor], nil];
	else
		pageFrontShadow.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[self flipShadowColor].CGColor, (id)[[[self flipShadowColor] colorWithAlphaComponent:0.5] CGColor], nil];
	pageFrontShadow.startPoint = CGPointMake(vertical? 0.5 : forwards? 0 : 0.5, vertical? forwards? 0 : 0.5 : 0.5);
	pageFrontShadow.endPoint = CGPointMake(vertical? 0.5 : forwards? 0.5 : 1, vertical? forwards? 0.5 : 1 : 0.5);
	pageFrontShadow.locations = [NSArray arrayWithObjects:[NSNumber numberWithDouble:0], [NSNumber numberWithDouble:forwards? 0.1 : 0.9], [NSNumber numberWithDouble:1], nil];
	
	pageBackShadow = [CAGradientLayer layer];
	[pageBack addSublayer:pageBackShadow];
	pageBackShadow.frame = CGRectInset(pageBack.bounds, insets.left, insets.top);
	pageBackShadow.opacity = [self flippingPageShadowOpacity];
	if (forwards)
		pageBackShadow.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[self flipShadowColor].CGColor, (id)[[[self flipShadowColor] colorWithAlphaComponent:0.5] CGColor], nil];
	else
		pageBackShadow.colors = [NSArray arrayWithObjects:(id)[[[self flipShadowColor] colorWithAlphaComponent:0.5] CGColor], (id)[self flipShadowColor].CGColor, (id)[[UIColor clearColor] CGColor], nil];
	pageBackShadow.startPoint = CGPointMake(vertical? 0.5 : forwards? 0.5 : 0, vertical? forwards? 0.5 : 0 : 0.5);
	pageBackShadow.endPoint = CGPointMake(vertical? 0.5 : forwards? 1 : 0.5, vertical? forwards? 1 : 0.5 : 0.5);
	pageBackShadow.locations = [NSArray arrayWithObjects:[NSNumber numberWithDouble:0], [NSNumber numberWithDouble:forwards? 0.9 : 0.1], [NSNumber numberWithDouble:1], nil];
	
	if (!inward)
	{
		pageRevealShadow = [CALayer layer];
		[pageReveal addSublayer:pageRevealShadow];
		pageRevealShadow.frame = pageReveal.bounds;
		pageRevealShadow.backgroundColor = [self flipShadowColor].CGColor;
		pageRevealShadow.opacity = [self coveredPageShadowOpacity];
		
		pageFacingShadow = [CALayer layer];
		//[pageFacing addSublayer:pageFacingShadow]; // add later
		pageFacingShadow.frame = pageFacing.bounds;
		pageFacingShadow.backgroundColor = [self flipShadowColor].CGColor;
		pageFacingShadow.opacity = 0.0;
	}
	
	NSUInteger frameCount = ceilf((self.duration / 2) * 60); // Let's shoot for 60 FPS to ensure proper sine curve approximation
	// (I would use 60 FPS if we were animating size/shape/position/rotation via keyframes)
	
	// Perspective is best proportional to the height of the pieces being folded away, rather than a fixed value
	// the larger the piece being folded, the more perspective distance (zDistance) is needed.
	// m34 = -1/zDistance
	if ([self m34] == INFINITY)
		transform.m34 = -1.0/(height * 4.6666667);
	else
		transform.m34 = [self m34];
	if (inward)
		transform.m34 = -transform.m34; // flip perspective around
	mainView.layer.sublayerTransform = transform;
	
	NSString *rotationKey = vertical? @"transform.rotation.x" : @"transform.rotation.y";
	double factor = (forwards? -1 : 1) * (vertical? -1 : 1) * M_PI / 180;
	CGFloat coveredPageShadowOpacity = [self coveredPageShadowOpacity];
	
	// Create a transaction (to group our animations with a single callback when done)
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:self.duration/2] forKey:kCATransactionAnimationDuration];
	[CATransaction setValue:[CAMediaTimingFunction functionWithName:[self timingCurveFunctionNameFirstHalf]] forKey:kCATransactionAnimationTimingFunction];
	[CATransaction setCompletionBlock:^{
		// Second half of animation
		pageBack.transform = CATransform3DMakeRotation(-90*factor, vertical? 1 : 0, vertical? 0 : 1, 0); // pre-rotate layer
		
		// don't animate adding/removing sublayers
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
		[pageFront removeFromSuperlayer];
		[pageRevealShadow removeFromSuperlayer];
		[mainView.layer addSublayer:pageBack];
		[pageFacing addSublayer:pageFacingShadow];
		[CATransaction commit];
		
		[CATransaction begin];
		[CATransaction setValue:[NSNumber numberWithFloat:self.duration/2] forKey:kCATransactionAnimationDuration];
		[CATransaction setValue:[CAMediaTimingFunction functionWithName:[self timingCurveFunctionNameSecondHalf]] forKey:kCATransactionAnimationTimingFunction];
		[CATransaction setCompletionBlock:^{
			// This is the final completion block, when 2nd half of animation finishes
			[mainView removeFromSuperview];
			[self transitionDidComplete];
			if (completion)
				completion(YES); // execute the completion block that was passed in
		}];
		
		// Flip back page from vertical down to flat
		CABasicAnimation* animation2 = [CABasicAnimation animationWithKeyPath:rotationKey];
		[animation2 setFromValue:[NSNumber numberWithDouble:-90*factor]];
		[animation2 setToValue:[NSNumber numberWithDouble:0]];
		[animation2 setFillMode:kCAFillModeForwards];
		[animation2 setRemovedOnCompletion:NO];
		[pageBack addAnimation:animation2 forKey:nil];
		
		// Shadows
		
		// Lighten back page just slightly as we flip (just to give it a crease where it touches reveal page)
		animation2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
		[animation2 setFromValue:[NSNumber numberWithDouble:[self flippingPageShadowOpacity]]];
		[animation2 setToValue:[NSNumber numberWithDouble:0]];
		[animation2 setFillMode:kCAFillModeForwards];
		[animation2 setRemovedOnCompletion:NO];
		[pageBackShadow addAnimation:animation2 forKey:nil];
		
		if (!inward)
		{
			// Darken facing page as it gets covered by back page flipping down (along a sine curve)
			NSMutableArray* arrayOpacity = [NSMutableArray arrayWithCapacity:frameCount + 1];
			CGFloat progress;
			CGFloat sinOpacity;
			for (int frame = 0; frame <= frameCount; frame++)
			{
				progress = (((float)frame) / frameCount);
				sinOpacity = (sin(mp_radians(90 * progress))* coveredPageShadowOpacity);
				if (frame == 0)
					sinOpacity = 0;
				[arrayOpacity addObject:[NSNumber numberWithFloat:sinOpacity]];
			}
			
			CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
			[keyAnimation setValues:[NSArray arrayWithArray:arrayOpacity]];
			[keyAnimation setFillMode:kCAFillModeForwards];
			[keyAnimation setRemovedOnCompletion:NO];
			[pageFacingShadow addAnimation:keyAnimation forKey:nil];
		}
		
		// Commit the transaction for 2nd half
		[CATransaction commit];
	}];
	
	// First Half of Animation
	
	// Flip front page from flat up to vertical
	CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:rotationKey];
	[animation setFromValue:[NSNumber numberWithDouble:0]];
	[animation setToValue:[NSNumber numberWithDouble:90*factor]];
	[animation setFillMode:kCAFillModeForwards];
	[animation setRemovedOnCompletion:NO];
	[pageFront addAnimation:animation forKey:nil];
	
	// Shadows
	
	// darken front page just slightly as we flip (just to give it a crease where it touches facing page)
	animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	[animation setFromValue:[NSNumber numberWithDouble:0]];
	[animation setToValue:[NSNumber numberWithDouble:[self flippingPageShadowOpacity]]];
	[animation setFillMode:kCAFillModeForwards];
	[animation setRemovedOnCompletion:NO];
	[pageFrontShadow addAnimation:animation forKey:nil];
	
	if (!inward)
	{
		// lighten the page that is revealed by front page flipping up (along a cosine curve)
		NSMutableArray* arrayOpacity = [NSMutableArray arrayWithCapacity:frameCount + 1];
		CGFloat progress;
		CGFloat cosOpacity;
		for (int frame = 0; frame <= frameCount; frame++)
		{
			progress = (((float)frame) / frameCount);
			cosOpacity = (cos(mp_radians(90 * progress))* coveredPageShadowOpacity);
			if (frame == frameCount)
				cosOpacity = 0;
			[arrayOpacity addObject:[NSNumber numberWithFloat:cosOpacity]];
		}
		
		CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
		[keyAnimation setValues:[NSArray arrayWithArray:arrayOpacity]];
		[keyAnimation setFillMode:kCAFillModeForwards];
		[keyAnimation setRemovedOnCompletion:NO];
		[pageRevealShadow addAnimation:keyAnimation forKey:nil];
	}
	
	// Commit the transaction for 1st half
	[CATransaction commit];
}

#pragma mark - Class methods

+ (void)transitionFromViewController:(UIViewController *)fromController toViewController:(UIViewController *)toController duration:(NSTimeInterval)duration style:(MPFlipStyle)style completion:(void (^)(BOOL finished))completion
{
	MPFlipTransition *flipTransition = [[MPFlipTransition alloc] initWithSourceView:fromController.view destinationView:toController.view duration:duration style:style completionAction:MPTransitionActionNone];
	[flipTransition perform:completion];
}

+ (void)transitionFromView:(UIView *)fromView toView:(UIView *)toView duration:(NSTimeInterval)duration style:(MPFlipStyle)style transitionAction:(MPTransitionAction)action completion:(void (^)(BOOL finished))completion
{
	MPFlipTransition *flipTransition = [[MPFlipTransition alloc] initWithSourceView:fromView destinationView:toView duration:duration style:style completionAction:action];
	[flipTransition perform:completion];
}

+ (void)presentViewController:(UIViewController *)viewControllerToPresent from:(UIViewController *)presentingController duration:(NSTimeInterval)duration style:(MPFlipStyle)style completion:(void (^)(BOOL finished))completion
{		
	MPFlipTransition *flipTransition = [[MPFlipTransition alloc] initWithSourceView:presentingController.view destinationView:viewControllerToPresent.view duration:duration style:style completionAction:MPTransitionActionNone];
	
	[flipTransition setPresentingController:presentingController];
	
	[flipTransition perform:^(BOOL finished) {
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

+ (void)dismissViewControllerFromPresentingController:(UIViewController *)presentingController duration:(NSTimeInterval)duration style:(MPFlipStyle)style completion:(void (^)(BOOL finished))completion
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
	
	MPFlipTransition *flipTransition = [[MPFlipTransition alloc] initWithSourceView:src.view destinationView:dest.view duration:duration style:style completionAction:MPTransitionActionNone];
	[flipTransition setDismissing:YES];
	[presentingController dismissViewControllerAnimated:NO completion:nil];
	[flipTransition perform:^(BOOL finished) {
		[dest.view setHidden:NO];
		if (completion)
			completion(YES);
	}];
}

@end

#pragma mark - UIViewController(MPFlipTransition)

@implementation UIViewController(MPFlipTransition)

- (void)presentViewController:(UIViewController *)viewControllerToPresent flipStyle:(MPFlipStyle)style completion:(void (^)(BOOL finished))completion
{
	[MPFlipTransition presentViewController:viewControllerToPresent from:self duration:[MPFlipTransition defaultDuration] style:style completion:completion];
}

- (void)dismissViewControllerWithFlipStyle:(MPFlipStyle)style completion:(void (^)(BOOL finished))completion
{
	[MPFlipTransition dismissViewControllerFromPresentingController:self duration:[MPFlipTransition defaultDuration] style:style completion:completion];
}

@end

#pragma mark - UINavigationController(MPFlipTransition)

@implementation UINavigationController(MPFlipTransition)

//- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
- (void)pushViewController:(UIViewController *)viewController flipStyle:(MPFlipStyle)style
{
	[MPFlipTransition transitionFromViewController:[self visibleViewController] 
								  toViewController:viewController 
										  duration:[MPFlipTransition defaultDuration]  
											 style:style 
										completion:^(BOOL finished) {
											[self pushViewController:viewController animated:NO];
										}
	 ];
}

- (UIViewController *)popViewControllerWithFlipStyle:(MPFlipStyle)style
{
	UIViewController *toController = [[self viewControllers] objectAtIndex:[[self viewControllers] count] - 2];
	
	[MPFlipTransition transitionFromViewController:[self visibleViewController] 
								  toViewController:toController 
										  duration:[MPFlipTransition defaultDuration] 
											 style:style
										completion:^(BOOL finished) {
											[self popViewControllerAnimated:NO];
										}
	 ];
	
	return toController;
}

@end
