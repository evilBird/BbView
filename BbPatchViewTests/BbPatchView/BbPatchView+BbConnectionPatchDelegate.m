//
//  BbPatchView+BbConnectionPatchDelegate.m
//  Pods
//
//  Created by Travis Henspeter on 1/12/16.
//
//

#import "BbPatchView.h"

@implementation BbPatchView (BbConnectionPathDelegate)

- (void)redrawConnectionPath:(id<BbConnectionPath>)connectionPath
{
    [self.connectionPathsToRedraw addObject:connectionPath];
    [self redrawConnectionsIfNeeded];
}

- (void)addConnectionPath:(id<BbConnectionPath>)connectionPath
{
    [self.connectionPaths addObject:connectionPath];
    [self.connectionPathsToRedraw addObject:connectionPath];
    [self redrawConnectionsIfNeeded];
}

- (void)removeConnectionPath:(id<BbConnectionPath>)connectionPath
{
    [self.connectionPaths removeObject:connectionPath];
    [connectionPath removeFromParentView];
}

@end
