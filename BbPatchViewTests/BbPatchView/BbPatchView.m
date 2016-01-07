//
//  BbPatchView.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 1/6/16.
//  Copyright © 2016 birdSound LLC. All rights reserved.
//

#import "BbPatchView.h"
#import "BbBoxView.h"
#import "BbPortView.h"
#import "UIView+BbPatch.h"
#import "BbPatchGestureRecognizer.h"

@interface BbPatchView () <UIGestureRecognizerDelegate>

@property (nonatomic,weak)          BbInletView                         *selectedInlet;
@property (nonatomic,weak)          BbOutletView                        *selectedOutlet;
@property (nonatomic,weak)          BbBoxView                           *selectedBox;

@property (nonatomic,strong)        NSMutableArray                      *boxViews;
@property (nonatomic,strong)        BbPatchGestureRecognizer            *gesture;

@property (nonatomic,strong)        NSArray                             *viewTypes;
@property (nonatomic)               BbPatchViewType                     firstViewType;
@property (nonatomic)               BbPatchViewType                     currentViewType;
@property (nonatomic)               BbPatchViewType                     lastViewType;

@property (nonatomic,strong)        UIBezierPath                        *activeConnection;

@end

@implementation BbPatchView

#pragma mark - Constructors

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self ) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    self.gesture = [[BbPatchGestureRecognizer alloc]initWithTarget:self action:@selector(handleGesture:)];
    self.gesture.cancelsTouchesInView = NO;
    self.gesture.delaysTouchesBegan = YES;
    self.gesture.delaysTouchesEnded = YES;
    self.gesture.delegate = self;
    [self addGestureRecognizer:self.gesture];
}

#pragma mark - Public methods

- (void)addBoxView:(BbBoxView *)boxView atPoint:(CGPoint)point
{
    if ( nil == self.boxViews ) {
        self.boxViews = [NSMutableArray array];
    }
    
    if ( nil == boxView || [self.boxViews containsObject:boxView] ) {
        return;
    }
    
    [self.boxViews addObject:boxView];
    [self addSubview:boxView];
    [self addConstraints:[boxView positionConstraints]];
    [boxView setPosition:[self point2Position:point]];
}

#pragma mark - Gestures

- (void)handleGesture:(BbPatchGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self handleGestureBegan:gesture];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            [self handleGestureMoved:gesture];
        }
            break;
        case UIGestureRecognizerStateCancelled:
        {
            [self handleGestureCancelled:gesture];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [self handleGestureEnded:gesture];
        }
            break;
            
        default:
            break;
    }
}

- (void)handleGestureBegan:(BbPatchGestureRecognizer *)gesture
{
    BbPatchViewType type = [self viewType:gesture.firstView];
    self.firstViewType = type;
    
    switch (gesture.numberOfTouches) {
        case 1:
        {
            self.firstViewType = type;
            switch (type) {
                    
                case BbPatchViewType_Object:
                {
                    //Select view and prepare to pan or move
                    [self.delegate patchView:self setScrollViewShouldBegin:NO];
                    self.selectedBox = (BbBoxView *)gesture.firstView;
                }
                    break;
                case BbPatchViewType_Outlet:
                {
                    //Select outlet and prepare to draw connection
                    [self.delegate patchView:self setScrollViewShouldBegin:NO];
                    self.selectedOutlet = (BbOutletView *)gesture.firstView;
                    
                }
                    break;
                default:
                    [gesture stopTracking];
                    [self.delegate patchView:self setScrollViewShouldBegin:YES];
                    break;
            }
        }
            break;
            
        default:
            //TO DO: Handle multi touch?
            [gesture stopTracking];
            [self.delegate patchView:self setScrollViewShouldBegin:YES];
            
            break;
    }
}

- (void)handleGestureMoved:(BbPatchGestureRecognizer *)gesture
{
    BbPatchViewType type = [self viewType:gesture.currentView];
    self.currentViewType = type;
    
    switch (gesture.numberOfTouches) {
        case 1:
        {
            switch (type) {
                case BbPatchViewType_Inlet:
                {
                    if ( nil != self.selectedOutlet ) {
                        self.selectedInlet = (BbInletView *)gesture.currentView;
                    }
                }
                    break;
                    
                default:
                    self.selectedInlet = nil;
                    
                    switch (self.firstViewType) {
                        case BbPatchViewType_Object:
                        {
                            if ( nil == self.selectedBox ) {
                                return;
                            }
                            
                            CGPoint pos = [self positionForBoxView:self.selectedBox withDeltaPos:gesture.deltaPosition];
                            [self.selectedBox setPosition:pos];
                        }
                            break;
                        case BbPatchViewType_Outlet:
                        {
                            [self setNeedsDisplay];
                        }
                            break;
                        default:
                            break;
                    }
                    break;
            }
        }
            break;
            
        default:
            [self.delegate patchView:self setScrollViewShouldCancel:NO];
            break;
    }
}

- (void)handleGestureCancelled:(BbPatchGestureRecognizer *)gesture
{
    NSLog(@"gesture cancelled");
}

- (void)handleGestureEnded:(BbPatchGestureRecognizer *)gesture
{
    BbPatchViewType type = [self viewType:gesture.currentView];
    self.lastViewType = type;
    switch (gesture.numberOfTouches) {
        case 1:
        {
            switch (type) {
                case BbPatchViewType_Inlet:
                {
                    if ( nil!=self.selectedOutlet && nil!= self.selectedOutlet ) {
                        NSLog(@"WE'VE GOT A NEW CONNECTION!");
                    }
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            
            break;
    }
    
    self.selectedInlet = nil;
    self.selectedOutlet = nil;
    self.selectedBox = nil;
    [self.activeConnection removeAllPoints];
    self.activeConnection = nil;
    [self setNeedsDisplay];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ( nil != self.selectedBox || nil != self.selectedOutlet ) {
        return NO;
    }
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

#pragma mark - Accessors

- (void)setSelectedBox:(BbBoxView *)selectedBox
{
    BbBoxView *prevSelBox = _selectedBox;
    _selectedBox = selectedBox;
    if ( nil == _selectedBox ) {
        prevSelBox.selected = NO;
    }else{
        _selectedBox.selected = YES;
        [self.delegate patchView:self setScrollViewShouldBegin:NO];
    }
}

- (void)setSelectedInlet:(BbInletView *)selectedInlet
{
    BbInletView *prevSelInlet = _selectedInlet;
    _selectedInlet = selectedInlet;
    if ( nil == _selectedInlet) {
        prevSelInlet.selected = NO;
    }else{
        _selectedInlet.selected = YES;
    }
}

- (void)setSelectedOutlet:(BbOutletView *)selectedOutlet
{
    BbOutletView *prevSelOutlet = _selectedOutlet;
    _selectedOutlet = selectedOutlet;
    if ( nil == _selectedOutlet ){
        prevSelOutlet.selected = NO;
    }else{
        _selectedOutlet.selected = YES;
        [self.delegate patchView:self setScrollViewShouldBegin:NO];
    }
}

#pragma mark - Helpers

- (BbPatchViewType)viewType:(id)view
{
    if ( nil == self.viewTypes ) {
        self.viewTypes = [BbPatchView myViewTypes];
    }
    
    BbPatchViewType type = ( [self.viewTypes containsObject:[view class]] ) ? (BbPatchViewType)[ self.viewTypes indexOfObject:[view class] ] : BbPatchViewType_Unknown;
    return type;
}

- (CGPoint)clampPosition:(CGPoint)position forBoxView:(BbBoxView *)box
{
    CGSize size = box.intrinsicContentSize;
    CGRect bounds = self.bounds;
    
    CGFloat leftEdgeOffset = -bounds.size.width/2.0;
    CGFloat rightEdgeOffset = bounds.size.width/2.0;
    CGFloat topEdgeOffset = -bounds.size.height/2.0;
    CGFloat bottomEdgeOffset = bounds.size.height/2.0;
    CGFloat minX = leftEdgeOffset+size.width/2.0;
    CGFloat maxX = rightEdgeOffset-size.width/2.0;
    CGFloat minY = topEdgeOffset+size.height/2.0;
    CGFloat maxY = bottomEdgeOffset-size.height/2.0;
    
    if ( position.x < minX ) {
        position.x = minX;
    }
    
    if ( position.x > maxX ) {
        position.x = maxX;
    }
    
    if ( position.y < minY ) {
        position.y = minY;
    }
    
    if ( position.y > maxY ) {
        position.y = maxY;
    }
    
    return position;
}

- (CGPoint)positionForBoxView:(BbBoxView *)box withDeltaPos:(CGPoint)deltaPos
{
    CGPoint pos = [box getPosition];
    pos.x+=deltaPos.y;
    pos.y+=deltaPos.x;
    return pos;
}

- (CGPoint)connectionOrigin
{
    if ( nil == self.selectedOutlet ) {
        return CGPointZero;
    }
    CGPoint origin = [self convertPoint:self.selectedOutlet.center fromView:self.selectedOutlet.superview];
    return origin;
}

+ (NSArray *)myViewTypes
{
    return @[[BbPatchView class],
             [BbBoxView class],
             [BbInletView class],
             [BbOutletView class]
             ];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if ( nil != self.selectedOutlet ) {
        [[UIColor blackColor]setStroke];
        CGPoint connectionOrigin = [self connectionOrigin];
        self.activeConnection = [UIBezierPath bezierPath];
        self.activeConnection.lineWidth = 8;
        [self.activeConnection moveToPoint:connectionOrigin];
        [self.activeConnection addLineToPoint:self.gesture.location];
        [self.activeConnection stroke];
    }
}


@end
