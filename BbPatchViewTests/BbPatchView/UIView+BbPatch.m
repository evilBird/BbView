//
//  UIView+BbPatch.m
//  BbPatchViewTests
//
//  Created by Travis Henspeter on 1/6/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "UIView+BbPatch.h"

@implementation UIView (BbPatch)

CGPoint CGPointGetOffset(CGPoint point, CGPoint referencePoint)
{
    CGFloat dx = point.x-referencePoint.x;
    CGFloat dy = point.y-referencePoint.y;
    return CGPointMake(dx, dy);
}

- (CGPoint)point2Position:(CGPoint)point
{
    CGPoint center = self.center;
    CGPoint position;
    position.x = (point.x - center.x);
    position.y = (point.y - center.y);
    return position;
}

@end
