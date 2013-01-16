//
//  MPFoldEnumerations.h
//  MPFoldTransition (v1.0.1)
//
//  Created by Mark Pospesel on 4/26/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#ifndef MPFoldTransition_MPFoldEnumerations_h
#define MPFoldTransition_MPFoldEnumerations_h

// Bit 0: Fold vs. Unfold
// Fold = view disappears by folding away from user into center to nothing
// Unfold = view appears from nothing by unfolding from center

// Bit 1: Normal vs. Cubic
// Normal = Top & bottom (or left & right for Horizontal) sleeves are flat and slide into/out of view as center view folds/unfolds
// Cubic = Top & bottom (or left & right for Horizontal) sleeves are fixed at 90 degree angles to the central folding panels,
//     so that they unfold/fold as center view folds/unfolds.

// Bit 2: Vertical vs. Horizontal
// Vertical = view folds/unfolds into top & bottom halves
// Horizontal = view folds/unfolds into left & right halves

enum {
	// current view folds away into center, next view slides in flat from top & bottom
	MPFoldStyleDefault		= 0,
	MPFoldStyleUnfold		= 1 << 0,
	MPFoldStyleCubic		= 1 << 1,
	MPFoldStyleHorizontal	= 1 << 2
};
typedef NSUInteger MPFoldStyle;

static inline MPFoldStyle MPFoldStyleFlipFoldBit(MPFoldStyle style) { return (style & ~MPFoldStyleUnfold) | ((style & MPFoldStyleUnfold) == MPFoldStyleUnfold? 0 : MPFoldStyleUnfold); }

#endif
