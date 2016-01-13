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

static NSTimeInterval       kLongPressMinDuration = 0.5;
static CGFloat              kMaxMovement          = 20.0;

@interface BbPatchView () <UIGestureRecognizerDelegate>

@property (nonatomic,weak)          BbInletView                         *selectedInlet;
@property (nonatomic,weak)          BbOutletView                        *selectedOutlet;
@property (nonatomic,weak)          BbBoxView                           *selectedBox;

@property (nonatomic,strong)        BbPatchGestureRecognizer            *gesture;

@property (nonatomic,strong)        NSArray                             *viewTypes;
@property (nonatomic)               BbPatchViewType                     firstViewType;
@property (nonatomic)               BbPatchViewType                     currentViewType;
@property (nonatomic)               BbPatchViewType                     lastViewType;

@property (nonatomic,strong)        UIBezierPath                        *activeConnection;

@property (nonatomic)               NSUInteger                          hasSelectedObject;
@property (nonatomic)               NSUInteger                          hasSelectedOutlet;
@property (nonatomic)               NSUInteger                          hasSelectedInlet;


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

- (instancetype)initWithDataSource:(id<BbObjectViewDataSource>)dataSource
{
    self = [super initWithFrame:CGRectZero];
    if ( self ) {
        _dataSource = dataSource;
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
    self.connectionPaths = [[NSMutableSet alloc]init];
    self.connectionPathsToRedraw = [[NSMutableSet alloc]init];
    self.childViews = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
}

#pragma mark - Gestures

- (void)handleGesture:(BbPatchGestureRecognizer *)gesture
{
    if ( gesture.state == UIGestureRecognizerStateCancelled ) {
        [self resetGestureStateConditions];
    }else if ( gesture.numberOfTouches > 1 ){
        [self.gesture stopTracking];
    }
    
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
    self.currentViewType = [self viewType:gesture.firstView];
    self.firstViewType = self.currentViewType;
    BOOL isEditing = ( self.editState > BbObjectViewEditState_Default );
    id<BbObjectView> objectView = (id<BbObjectView>)gesture.firstView;
    
    switch (self.firstViewType) {
        
        case BbPatchViewType_Object:
        case BbPatchViewType_ObjectSubview:
        {
            //Select view and prepare to pan or move
            [self.eventDelegate patchView:self setScrollViewShouldBegin:NO];
            UIView *first = gesture.firstView;
            self.selectedBox = ( self.firstViewType == BbPatchViewType_Object ) ? (BbBoxView *)first : (BbBoxView *)first.superview;
        }
            break;
        case BbPatchViewType_Outlet:
        {
            if ( isEditing ) {
                [gesture stopTracking];
                return;
            }
            //Select outlet and prepare to draw connection
            [self.eventDelegate patchView:self setScrollViewShouldBegin:NO];
            self.selectedOutlet = (BbOutletView *)gesture.firstView;
            
        }
            break;
        case BbPatchViewType_ActionObject:
        {
            [self.eventDelegate patchView:self setScrollViewShouldBegin:NO];
            if ( isEditing ) {
                //send object actions
                [[objectView delegate]sendActionsForObjectView:objectView];
            }
        }
            break;
        case BbPatchViewType_Patch:
        {
            if ( !gesture.repeatCount ) {
                [gesture stopTracking];
                [self.eventDelegate patchView:self setScrollViewShouldBegin:YES];
            }
        }
            break;
        default:
        {
            [gesture stopTracking];
            [self.eventDelegate patchView:self setScrollViewShouldBegin:YES];
        }
            break;
    }

}

- (void)handleGestureMoved:(BbPatchGestureRecognizer *)gesture
{
    self.currentViewType = [self viewType:gesture.currentView];
    BOOL isEditing = ( self.editState > BbObjectViewEditState_Default );
    NSLog(@"gesture moved to view type: %@",@(self.currentViewType));
    switch (self.currentViewType) {
            
        case BbPatchViewType_Inlet:
        {
            if ( !isEditing && nil != self.selectedOutlet ) {
                self.selectedInlet = (BbInletView *)gesture.currentView;
                NSLog(@"we have a selected inlet!");
            }else{
                NSLog(@"current view is an inlet, but editing is %@ and selected outlet is %@",@(isEditing),self.selectedOutlet);
            }
        }
            break;
            
        default:
            
            self.selectedInlet = nil;
            
            switch (self.firstViewType) {
                case BbPatchViewType_Object:
                {
                    if ( !isEditing && !self.hasSelectedObject ) {
                        [gesture stopTracking];
                        return;
                    }
                    if ( isEditing ) {
                        NSArray *selected = [self getSelectedBoxViews];
                        //Move selected
                    }else if ( self.hasSelectedObject ){
                        CGPoint pos = [self positionForBoxView:self.selectedBox withDeltaPos:gesture.deltaPosition];
                        [self.selectedBox setPosition:pos];
                    }
                }
                    break;
                case BbPatchViewType_Outlet:
                {
                    if ( !isEditing ) {
                        //Draw connection
                        [self setNeedsDisplay];
                    }
                }
                    break;
                    
                default:
                    
                    break;
            }
            break;
    }
}

- (void)handleGestureEnded:(BbPatchGestureRecognizer *)gesture
{
    self.currentViewType = [self viewType:gesture.currentView];
    BOOL isEditing = ( self.editState > BbObjectViewEditState_Default );
    switch ( self.currentViewType ) {
            
        case BbPatchViewType_Inlet:
        {
            if ( !isEditing && nil != self.selectedInlet && nil != self.selectedOutlet ) {
                //make connection
                [self.delegate objectView:self didConnectPortView:self.selectedOutlet toPortView:self.selectedInlet];
            }else{
                
            }
        }
            break;
        case BbPatchViewType_Patch:
        {
            if ( !isEditing && gesture.repeatCount && gesture.movement < kMaxMovement ) {
                // add box
                CGPoint point = gesture.position;
                NSValue *pos = [NSValue valueWithCGPoint:[self point2Position:point]];
                [self.delegate objectView:self didRequestPlaceholderViewAtPosition:pos];
            }
        }
            break;
        case BbPatchViewType_Object:
        {
            if ( !isEditing ) {
                if ( gesture.repeatCount && gesture.movement < kMaxMovement ) {
                    //show box options
                }else if ( gesture.duration > kLongPressMinDuration  && gesture.movement < kMaxMovement ){
                    //edit box
                }
            }
        }
            break;
        case BbPatchViewType_ActionObject:
        {
            if ( !isEditing ) {
                
            }
        }
        default:
            break;
    }
    
    [self resetGestureStateConditions];
}

- (void)resetGestureStateConditions
{
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
        self.hasSelectedObject = NO;
    }else{
        _selectedBox.selected = YES;
        self.hasSelectedObject = YES;
        [self.eventDelegate patchView:self setScrollViewShouldBegin:NO];
    }
}

- (void)setSelectedInlet:(BbInletView *)selectedInlet
{
    BbInletView *prevSelInlet = _selectedInlet;
    _selectedInlet = selectedInlet;
    if ( nil == _selectedInlet) {
        prevSelInlet.selected = NO;
        self.hasSelectedInlet = NO;
    }else{
        _selectedInlet.selected = YES;
        self.hasSelectedInlet = YES;
    }
}

- (void)setSelectedOutlet:(BbOutletView *)selectedOutlet
{
    BbOutletView *prevSelOutlet = _selectedOutlet;
    _selectedOutlet = selectedOutlet;
    if ( nil == _selectedOutlet ){
        prevSelOutlet.selected = NO;
        self.hasSelectedOutlet = NO;
    }else{
        _selectedOutlet.selected = YES;
        self.hasSelectedInlet = YES;
        [self.eventDelegate patchView:self setScrollViewShouldBegin:NO];
    }
}

- (NSArray *)getSelectedBoxViews
{
    NSArray *children = self.childViews.allObjects;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == 1",@"selected"];
    return [children filteredArrayUsingPredicate:pred];
}

#pragma mark - BbGestureHandlerHost

#pragma mark - Helpers

- (BbPatchViewType)viewType:(id)view
{
    if ( nil == self.viewTypes ) {
        self.viewTypes = [BbPatchView myViewTypes];
    }
    
    BbPatchViewType type = ( [self.viewTypes containsObject:[view class]] ) ? (BbPatchViewType)[ self.viewTypes indexOfObject:[view class] ] : BbPatchViewType_Unknown;
    
    if ( type != BbPatchViewType_Unknown ) {
        return type;
    }else{
        id superview = [(UIView *)view superview];
        BbPatchViewType superviewType = ( [self.viewTypes containsObject:[superview class]] ) ? (BbPatchViewType)[ self.viewTypes indexOfObject:[superview class] ] : BbPatchViewType_Unknown;
        if ( superviewType == BbPatchViewType_Object ) {
            return BbPatchViewType_ObjectSubview;
        }
    }
    
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
    CGPoint pos = box.center;
    pos.x+=deltaPos.x;
    pos.y+=deltaPos.y;
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

- (void)redrawConnectionsIfNeeded
{
    [self setNeedsDisplay];
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
    
    if ( self.connectionPathsToRedraw.allObjects.count ) {
        for (BbConnectionPath *connectionPath in self.connectionPathsToRedraw ) {
            if (nil != [connectionPath sendingView] && nil != [connectionPath receivingView] ){
               CGPoint origin = [self convertPoint:[connectionPath sendingView].center fromView:[connectionPath sendingView].superview];
                CGPoint terminus = [self convertPoint:[connectionPath receivingView].center fromView:[connectionPath receivingView].superview];
                UIBezierPath *path = [UIBezierPath bezierPath];
                [path moveToPoint:origin];
                [path addLineToPoint:terminus];
                [path setLineWidth:6];
                [connectionPath.preferredColor setStroke];
                [path stroke];
            }
        }
        
       // [self.connectionPathsToRedraw removeAllObjects];
    }
}


@end
