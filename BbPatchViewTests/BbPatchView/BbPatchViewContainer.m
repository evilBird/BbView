//
//  BbPatchViewContainer.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 1/6/16.
//  Copyright © 2016 birdSound LLC. All rights reserved.
//

#import "BbPatchViewContainer.h"
#import "BbScrollView.h"
#import "BbPatchView.h"
#import "UIView+Layout.h"
#import "BbBoxView.h"

@interface BbPatchViewContainer () <BbPatchViewDelegate,UIScrollViewDelegate>

@end

@implementation BbPatchViewContainer

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if ( self ) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self ) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    if ( self ) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    self.scrollView = [[BbScrollView alloc]initWithFrame:self.bounds];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = 0.5;
    self.scrollView.maximumZoomScale = 2.0;
    [self addSubview:self.scrollView];
    CGRect screen = [UIScreen mainScreen].bounds;
    CGSize patchViewSize = screen.size;
    CGFloat edge = ( patchViewSize.width >= patchViewSize.height ) ? ( patchViewSize.width ) : ( patchViewSize.height );
    edge*=2;
    CGRect patchViewRect = CGRectMake(0.0, 0.0, edge, edge);
    
    self.patchView = [[BbPatchView alloc]initWithFrame:patchViewRect];
    self.patchView.delegate = self;
    self.patchView.backgroundColor = [UIColor yellowColor];
    [self.scrollView addSubview:self.patchView];
    self.scrollView.contentSize = patchViewRect.size;
    [self addConstraints:[self.scrollView pinEdgesToSuperWithInsets:UIEdgeInsetsZero]];
}

- (void)testAddBoxes
{
    CGRect screen = self.bounds;
    BbBoxView *box = [[BbBoxView alloc]initWithTitleText:@"BbObject Args" inlets:2 outlets:1];
    CGPoint myCenter = CGPointMake(CGRectGetMidX(screen),CGRectGetMidY(screen));
    [self.patchView addBoxView:box atPoint:myCenter];
    CGPoint newPoint = myCenter;
    newPoint.x+=200;
    newPoint.y+=200;
    
    BbBoxView *box2 = [[BbBoxView alloc]initWithTitleText:@"BbDelegate UITableView" inlets:2 outlets:2];
    [self.patchView addBoxView:box2 atPoint:newPoint];
    
    newPoint = myCenter;
    newPoint.x -= 200;
    newPoint.y -= 200;
    
    BbBoxView *box3 = [[BbBoxView alloc]initWithTitleText:@"BbRect 0 0 200 200" inlets:4 outlets:3];
    [self.patchView addBoxView:box3 atPoint:newPoint];
    
    
}


#pragma mark - BbPatchViewDelegate

- (void)patchView:(id)sender setScrollViewShouldBegin:(BOOL)shouldBegin
{
    self.scrollView.touchesShouldBegin = shouldBegin;
}

- (void)patchView:(id)sender setScrollViewShouldCancel:(BOOL)shouldCancel
{
    self.scrollView.touchesShouldCancel = shouldCancel;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.patchView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self.patchView setNeedsDisplay];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [self.patchView setNeedsDisplay];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
