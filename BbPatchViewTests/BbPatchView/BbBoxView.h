//
//  BbBoxView.h
//  BbPatchViewTests
//
//  Created by Travis Henspeter on 1/6/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BbObjectView.h"
#import "BbObjectViewDataSource.h"

@class BbInletView;
@class BbOutletView;

@interface BbBoxView : UIView <BbObjectView>

@property (nonatomic,strong)                    UIColor                         *defaultFillColor;
@property (nonatomic,strong)                    UIColor                         *selectedFillColor;
@property (nonatomic,strong)                    UIColor                         *defaultBorderColor;
@property (nonatomic,strong)                    UIColor                         *selectedBorderColor;
@property (nonatomic,strong)                    UIColor                         *defaultTextColor;
@property (nonatomic,strong)                    UIColor                         *selectedTextColor;
@property (nonatomic,strong)                    NSArray                         *inletViews;
@property (nonatomic,strong)                    NSArray                         *outletViews;

@property (nonatomic,getter=isSelected)         BOOL                            selected;
@property (nonatomic,getter=isEditing)          BOOL                            editing;
@property (nonatomic,weak)                      id<BbObjectViewDataSource>      dataSource;

- (instancetype)initWithTitleText:(NSString *)text inlets:(NSUInteger)numInlets outlets:(NSUInteger)numOutlets;
- (void)setPosition:(CGPoint)position;
- (CGPoint)getPosition;
- (NSArray *)positionConstraints;

#pragma mark - BbObjectView

- (instancetype)initWithDataSource:(id<BbObjectViewDataSource>)dataSource;
- (id<BbObjectView>)viewForInletAtIndex:(NSUInteger)index;
- (id<BbObjectView>)viewForOutletAtIndex:(NSUInteger)index;

@end
