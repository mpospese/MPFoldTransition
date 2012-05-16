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

- (void)perform:(void (^)(BOOL finished))completion;

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
