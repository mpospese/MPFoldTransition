//
//  MPFlipEnumerations.h
//  MPTransition (v1.1.0)
//
//  Created by Mark Pospesel on 5/15/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#ifndef MPFoldTransition_MPFlipEnumerations_h
#define MPFoldTransition_MPFlipEnumerations_h

// Bit 0: Direction - Forward (unset) vs.Backward (set)
// Forward = page flip from right to left (horizontal) or bottom to top (vertical)
// Backward = page flip from left to right (horizontal) or top to bottom (vertical)

// Bit 1: Orientation - Horizontal (unset) vs. Vertical (set)
// Horizontal = page flips right to left about a vertical spine
// Vertical = page flips bottom to top about a horizontal spine

// Bit 2: Perspective - Normal (unset) vs. Reverse (set)
// Normal = page flips towards viewer
// Reverse = page flips away from viewer

// TODO: spine position (left, mid, right // top, mid, bottom)

enum {
	// current view folds away into center, next view slides in flat from top & bottom
	MPFlipStyleDefault				= 0,
	MPFlipStyleDirectionBackward	= 1 << 0,
	MPFlipStyleOrientationVertical	= 1 << 1,
	MPFlipStylePerspectiveReverse	= 1 << 2
};
typedef NSUInteger MPFlipStyle;

#define MPFlipStyleDirectionMask	MPFlipStyleDirectionBackward
#define MPFlipStyleOrientationMask	MPFlipStyleOrientationVertical
#define MPFlipStylePerspectiveMask	MPFlipStylePerspectiveReverse

static inline MPFlipStyle MPFlipStyleFlipDirectionBit(MPFlipStyle style) { return (style & ~MPFlipStyleDirectionMask) | ((style & MPFlipStyleDirectionMask) == MPFlipStyleDirectionBackward? 0 : MPFlipStyleDirectionBackward); }

#endif
