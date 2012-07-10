//
//  MPTransition.h
//  MPFoldTransition (v1.1.4)
//
//  Created by Mark Pospesel on 5/14/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPTransitionEnumerations.h"

typedef void (^CompletionBlock)(BOOL);


@interface MPTransition : NSObject

#pragma mark - Properties

@property (strong, nonatomic) UIView *sourceView;
@property (strong, nonatomic) UIView *destinationView;
@property (assign, nonatomic) NSTimeInterval duration;
@property (assign, nonatomic) CGRect rect;
@property (assign, nonatomic) MPTransitionAction completionAction;
@property (assign, nonatomic) UIViewAnimationCurve timingCurve;
@property (readonly, nonatomic) BOOL presentedControllerIncludesStatusBarInFrame;

// Perspective component of transformation (Advanced use only, generally don't need to adjust)
@property (assign, nonatomic) float m34;

// Special case of dismissing a modal view
@property (assign, nonatomic, getter = isDimissing) BOOL dismissing;

#pragma mark - init

- (id)initWithSourceView:(UIView *)sourceView destinationView:(UIView *)destinationView duration:(NSTimeInterval)duration timingCurve:(UIViewAnimationCurve)timingCurve completionAction:(MPTransitionAction)action;

#pragma mark - Instance methods

- (void)perform;
- (void)perform:(void (^)(BOOL finished))completion;

- (NSString *)timingCurveFunctionName;
- (void)transitionDidComplete;
- (void)setPresentingController:(UIViewController *)presentingController;
- (void)setPresentedController:(UIViewController *)presentedController;
- (CGRect)calculateRect;

#pragma mark - Class methods

+ (NSTimeInterval)defaultDuration;

@end

#pragma mark - UIView extensions

@interface UIView(MPAnimation)

+ (BOOL)subView:(UIView *)subView1 isAboveSubView:(UIView *)subView2;
+ (BOOL)subView:(UIView *)subView1 isBelowSubView:(UIView *)subView2;
- (BOOL)isAboveSiblingView:(UIView *)siblingView;
- (BOOL)isBelowSiblingView:(UIView *)siblingView;

@end