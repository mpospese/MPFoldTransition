//
//  MPFoldTransition.h
//  MPFoldTransition (v 1.0.0)
//
//  Created by Mark Pospesel on 4/4/12.
//  Copyright (c) 2012 Odyssey Computing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPFoldEnumerations.h"

typedef void (^CompletionBlock)(BOOL);


@interface MPFoldTransition : NSObject

@property (strong, nonatomic) UIView *sourceView;
@property (strong, nonatomic) UIView *destinationView;
@property (assign, nonatomic) NSTimeInterval duration;
@property (assign, nonatomic) CGRect rect;
@property (assign, nonatomic) MPFoldStyle style;
@property (assign, nonatomic) MPTransitionAction completionAction;
@property (assign, nonatomic) UIViewAnimationCurve timingCurve;

// Maximum shadow opacity (when fully folded)
@property (assign, nonatomic) CGFloat foldShadowOpacity;
// Adjustment factor to differentiate between 2 adjacent shadows (0 to 1, 1 = no difference)
@property (assign, nonatomic) CGFloat foldShadowAdjustmentFactor;
@property (strong, nonatomic) UIColor *foldShadowColor;

- (id)initWithSourceView:(UIView *)sourceView destinationView:(UIView *)destinationView duration:(NSTimeInterval)duration style:(MPFoldStyle)style completionAction:(MPTransitionAction)action;
- (void)perform;
- (void)perform:(void (^)(BOOL finished))completion;

+ (NSTimeInterval)defaultDuration;

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

// Convenience method extensions for UIViewController
@interface UIViewController(MPFoldTransition)

// present view controller modally with fold transition
// use like presentViewController:animated:completion:
- (void)presentViewController:(UIViewController *)viewControllerToPresent foldStyle:(MPFoldStyle)style completion:(void (^)(BOOL finished))completion;

// dismiss presented controller with fold transition
// use like dismissViewControllerAnimated:completion:
- (void)dismissViewControllerWithFoldStyle:(MPFoldStyle)style completion:(void (^)(BOOL finished))completion;
																		  
@end

// Convenience method extensions for UINavigationController
@interface UINavigationController(MPFoldTransition)

//- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
- (void)pushViewController:(UIViewController *)viewController foldStyle:(MPFoldStyle)style;

//- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
- (UIViewController *)popViewControllerWithFoldStyle:(MPFoldStyle)style;

@end
