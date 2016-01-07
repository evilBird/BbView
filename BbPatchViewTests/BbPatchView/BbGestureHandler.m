//
//  BbGestureHandler.m
//  BbPatchViewTests
//
//  Created by Travis Henspeter on 1/7/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbGestureHandler.h"

static void *XXContext  =   &XXContext;

@interface BbGestureHandler ()

@property (nonatomic,readonly)            NSMutableArray                             *keyPaths;
@property (nonatomic,readonly)            NSMutableArray                             *expressions;

@end

@implementation BbGestureHandler

- (instancetype)initWithHost:(id<BbGestureHandlerHost>)host
{
    self = [super init];
    if ( self ) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    
}

- (void)setKeyPath:(NSString *)keyPath forStateCondition:(BbGestureStateCondition)stateCondition
{
    
}

- (void)setExpression:(NSString *)expression forAction:(BbGestureAction)action
{
    
}

- (void)beginObservingGestures
{
    
}

- (void)endObservingGestures
{
    
}

@end
