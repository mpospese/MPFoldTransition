//
//  MPTransitionEnumerations.h
//  MPFoldTransition (v1.0.1)
//
//  Created by Mark Pospesel on 5/14/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#ifndef MPFoldTransition_MPTransitionEnumerations_h
#define MPFoldTransition_MPTransitionEnumerations_h

// Action to take upon completion of the transition
enum {
	MPTransitionActionAddRemove, // add/remove subViews upon completion
	MPTransitionActionShowHide,	 // show/hide subViews upon completion
	MPTransitionActionNone		 // take no action (use when container view controller will handle add/remove)
} typedef MPTransitionAction;


#endif
