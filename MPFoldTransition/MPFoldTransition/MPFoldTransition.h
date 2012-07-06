//
//  MPFoldTransition.h
//  MPFoldTransition (v1.0.1)
//
//  Created by Mark Pospesel on 4/4/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPFoldEnumerations.h"
#import "MPTransition.h"

@interface MPFoldTransition : MPTransition

#pragma mark - Properties

// Fold style
@property (assign, nonatomic) MPFoldStyle style;

// Maximum shadow opacity (when fully folded), default = 0.25
@property (assign, nonatomic) CGFloat foldShadowOpacity;

// Fold shadow color, default = black
@property (strong, nonatomic) UIColor *foldShadowColor;

#pragma mark - init methods

- (id)initWithSourceView:(UIView *)sourceView destinationView:(UIView *)destinationView duration:(NSTimeInterval)duration style:(MPFoldStyle)style completionAction:(MPTransitionAction)action;

#pragma mark - Instance methods

- (void)perform:(void (^)(BOOL finished))completion;

#pragma mark - Class methods

// For generic UIViewController transitions
+ (void)transitionFromViewController:(UIViewController *)fromController 
					toViewController:(UIViewController *)toController 
							duration:(NSTimeInterval)duration
						   style:(MPFoldStyle)style 
						  completion:(void (^)(BOOL finished))completion;

// For generic UIView transitions
+ (void)transitionFromView:(UIView *)fromView toView:(UIView *)toView duration:(NSTimeInterval)duration style:(MPFoldStyle)style transitionAction:(MPTransitionAction)action completion:(void (^)(BOOL finished))completion;

// To present a view controller modally
+ (void)presentViewController:(UIViewController *)viewControllerToPresent from:(UIViewController *)presentingController duration:(NSTimeInterval)duration style:(MPFoldStyle)style completion:(void (^)(BOOL finished))completion;

// To dismiss a modal view controller
+ (void)dismissViewControllerFromPresentingController:(UIViewController *)presentingController duration:(NSTimeInterval)duration style:(MPFoldStyle)style completion:(void (^)(BOOL finished))completion;

@end

#pragma mark - UIViewController extensions

// Convenience method extensions for UIViewController
@interface UIViewController(MPFoldTransition)

// present view controller modally with fold transition
// use like presentViewController:animated:completion:
- (void)presentViewController:(UIViewController *)viewControllerToPresent foldStyle:(MPFoldStyle)style completion:(void (^)(BOOL finished))completion;

// dismiss presented controller with fold transition
// use like dismissViewControllerAnimated:completion:
- (void)dismissViewControllerWithFoldStyle:(MPFoldStyle)style completion:(void (^)(BOOL finished))completion;
																		  
@end

#pragma mark - UINavigationController extensions

// Convenience method extensions for UINavigationController
@interface UINavigationController(MPFoldTransition)

//- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
- (void)pushViewController:(UIViewController *)viewController foldStyle:(MPFoldStyle)style;

//- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
- (UIViewController *)popViewControllerWithFoldStyle:(MPFoldStyle)style;

@end
