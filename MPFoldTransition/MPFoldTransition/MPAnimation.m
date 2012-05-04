//
//  MPAnimation.m
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 3/10/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import "MPAnimation.h"
#import <QuartzCore/QuartzCore.h>

@implementation MPAnimation

// Generates an image from the view (view must be opaque)
+ (UIImage *)renderImageFromView:(UIView *)view
{
	return [self renderImageFromView:view withRect:view.bounds];
}

// Generates an image from the (opaque) view where frame is a rectangle in the view's coordinate space.
// Pass in bounds to render the entire view, or another rect to render a subset of the view
+ (UIImage *)renderImageFromView:(UIView *)view withRect:(CGRect)frame
{
    // Create a new context of the desired size to render the image
	UIGraphicsBeginImageContextWithOptions(frame.size, YES, 0);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	[[UIColor redColor] set];
	UIRectFill((CGRect){CGPointZero, frame.size});
	
	// Translate it, to the desired position
	CGContextTranslateCTM(context, -frame.origin.x, -frame.origin.y);
    
    // Render the view as image
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    // Fetch the image   
    UIImage *renderedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Cleanup
    UIGraphicsEndImageContext();
    
    return renderedImage;
}

// Generates an image from the view with transparent margins.
// (CGRect)frame is a rectangle in the view's coordinate space- pass in bounds to render the entire view, or another rect to render a subset of the view
// (UIEdgeInsets)insets defines the size of the transparent margins to create
+ (UIImage *)renderImageFromView:(UIView *)view withRect:(CGRect)frame transparentInsets:(UIEdgeInsets)insets
{
	CGSize imageSizeWithBorder = CGSizeMake(frame.size.width + insets.left + insets.right, frame.size.height + insets.top + insets.bottom);
    // Create a new context of the desired size to render the image
	UIGraphicsBeginImageContextWithOptions(imageSizeWithBorder, UIEdgeInsetsEqualToEdgeInsets(insets, UIEdgeInsetsZero), 0);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Clip the context to the portion of the view we will draw
	CGContextClipToRect(context, (CGRect){{insets.left, insets.top}, frame.size});
	// Translate it, to the desired position
     CGContextTranslateCTM(context, -frame.origin.x + insets.left, -frame.origin.y + insets.top);
    
    // Render the view as image
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    // Fetch the image   
    UIImage *renderedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Cleanup
    UIGraphicsEndImageContext();
    
    return renderedImage;
}

// Generates a copy of the image with a 1 point transparent margin around it
+ (UIImage *)renderImageForAntialiasing:(UIImage *)image
{
	return [self renderImageForAntialiasing:image withInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
}

// Generates a copy of the image with transparent margins of size defined by the insets parameter
+ (UIImage *)renderImageForAntialiasing:(UIImage *)image withInsets:(UIEdgeInsets)insets
{
	CGSize imageSizeWithBorder = CGSizeMake([image size].width + insets.left + insets.right, [image size].height + insets.top + insets.bottom);
	
	// Create a new context of the desired size to render the image
	UIGraphicsBeginImageContextWithOptions(imageSizeWithBorder, UIEdgeInsetsEqualToEdgeInsets(insets, UIEdgeInsetsZero), 0);
	
	// The image starts off filled with clear pixels, so we don't need to explicitly fill them here	
	[image drawInRect:(CGRect){{insets.left, insets.top}, [image size]}];
	
    // Fetch the image   
    UIImage *renderedImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return renderedImage;
}


@end
