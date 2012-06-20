//
//  MPFlipTransition.h
//  MPTransition (v1.1.0)
//
//  Created by Mark Pospesel on 5/15/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import "MPFlipEnumerations.h"
#import "MPTransition.h"

@interface MPFlipTransition : MPTransition

#pragma mark - Properties

@property (assign, nonatomic) MPFlipStyle style;
@property (assign, nonatomic) CGFloat coveredPageShadowOpacity;
@property (assign, nonatomic) CGFloat flippingPageShadowOpacity;
@property (strong, nonatomic) UIColor *flipShadowColor;

#pragma mark - init

- (id)initWithSourceView:(UIView *)sourceView destinationView:(UIView *)destinationView duration:(NSTimeInterval)duration style:(MPFlipStyle)style completionAction:(MPTransitionAction)action;

#pragma mark - Instance methods

// builds the layers for the flip animation
- (void)buildLayers;

// performs the flip animation
- (void)perform:(void (^)(BOOL finished))completion;

// set view to any position within the 1st half of the animation
// progress ranges from 0 (start) to 1 (complete)
- (void)doFlip1:(CGFloat)progress;

// set view to any position within the 2nd half of the animation
// progress ranges from 0 (start) to 1 (complete)
- (void)doFlip2:(CGFloat)progress;

#pragma mark - Class methods

// For generic UIViewController transitions
+ (void)transitionFromViewController:(UIViewController *)fromController 
					toViewController:(UIViewController *)toController 
							duration:(NSTimeInterval)duration
							   style:(MPFlipStyle)style 
						  completion:(void (^)(BOOL finished))completion;

// For generic UIView transitions
+ (void)transitionFromView:(UIView *)fromView toView:(UIView *)toView duration:(NSTimeInterval)duration style:(MPFlipStyle)style transitionAction:(MPTransitionAction)action completion:(void (^)(BOOL finished))completion;

// To present a view controller modally
+ (void)presentViewController:(UIViewController *)viewControllerToPresent from:(UIViewController *)presentingController duration:(NSTimeInterval)duration style:(MPFlipStyle)style completion:(void (^)(BOOL finished))completion;

// To dismiss a modal view controller
+ (void)dismissViewControllerFromPresentingController:(UIViewController *)presentingController duration:(NSTimeInterval)duration style:(MPFlipStyle)style completion:(void (^)(BOOL finished))completion;

@end

#pragma mark - UIViewController extensions

// Convenience method extensions for UIViewController
@interface UIViewController(MPFlipTransition)

// present view controller modally with fold transition
// use like presentViewController:animated:completion:
- (void)presentViewController:(UIViewController *)viewControllerToPresent flipStyle:(MPFlipStyle)style completion:(void (^)(BOOL finished))completion;

// dismiss presented controller with fold transition
// use like dismissViewControllerAnimated:completion:
- (void)dismissViewControllerWithFlipStyle:(MPFlipStyle)style completion:(void (^)(BOOL finished))completion;

@end

#pragma mark - UINavigationController extensions

// Convenience method extensions for UINavigationController
@interface UINavigationController(MPFlipTransition)

//- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
- (void)pushViewController:(UIViewController *)viewController flipStyle:(MPFlipStyle)style;

//- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
- (UIViewController *)popViewControllerWithFlipStyle:(MPFlipStyle)style;

@end
