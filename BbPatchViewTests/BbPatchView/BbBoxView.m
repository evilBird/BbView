//
//  BbBoxView.m
//  BbPatchViewTests
//
//  Created by Travis Henspeter on 1/6/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbBoxView.h"
#import "UIView+Layout.h"
#import "BbPortView.h"

static CGFloat kDefaultPortViewSpacing = 10;

@interface BbBoxView ()

@property (nonatomic)               NSUInteger      numIn;
@property (nonatomic)               NSUInteger      numOut;

@property (nonatomic)               CGPoint         myPosition;
@property (nonatomic)               CGSize          myContentSize;
@property (nonatomic)               CGFloat         myMinimumSpacing;
@property (nonatomic,strong)        NSString        *myTitleText;
@property (nonatomic,strong)        UIColor         *myFillColor;
@property (nonatomic,strong)        UIColor         *myBorderColor;
@property (nonatomic,strong)        UIColor         *myTextColor;
@property (nonatomic,strong)        UILabel         *myLabel;
@property (nonatomic,strong)        UIStackView     *inletsStackView;
@property (nonatomic,strong)        UIStackView     *outletsStackView;
@property (nonatomic,strong)        NSLayoutConstraint  *centerXConstraint;
@property (nonatomic,strong)        NSLayoutConstraint  *centerYConstraint;
@property (nonatomic,strong)        NSLayoutConstraint  *inletStackRightEdge;
@property (nonatomic,strong)        NSLayoutConstraint  *outletStackRightEdge;

@end

@implementation BbBoxView

- (instancetype)initWithTitleText:(NSString *)text inlets:(NSUInteger)numInlets outlets:(NSUInteger)numOutlets
{
    self = [super init];
    if ( self ) {
        _myTitleText = text;
        _numIn = numInlets;
        _numOut = numOutlets;
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.defaultFillColor = [UIColor blackColor];
    self.defaultBorderColor = [UIColor darkGrayColor];
    self.defaultTextColor = [UIColor whiteColor];
    self.selectedFillColor = [UIColor colorWithWhite:0.3 alpha:1.0];
    self.selectedBorderColor = self.defaultBorderColor;
    self.selectedTextColor = self.defaultTextColor;
    self.myLabel = [UILabel new];
    self.myLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.myLabel];
    [self addConstraint:[self.myLabel alignCenterXToSuperOffset:0.0]];
    [self addConstraint:[self.myLabel alignCenterYToSuperOffset:0.0]];
    
    self.inletViews = [BbBoxView makeInletViews:self.numIn];
    self.outletViews = [BbBoxView makeOutletViews:self.numOut];
    
    if ( self.inletViews ) {
        self.inletsStackView = [[UIStackView alloc]initWithArrangedSubviews:self.inletViews];
        self.inletsStackView.translatesAutoresizingMaskIntoConstraints = NO;
        self.inletsStackView.axis = UILayoutConstraintAxisHorizontal;
        self.inletsStackView.distribution = UIStackViewDistributionEqualSpacing;
        self.inletsStackView.spacing = kDefaultPortViewSpacing;
        [self addSubview:self.inletsStackView];
        [self addConstraint:[self.inletsStackView pinEdge:LayoutEdge_Bottom toEdge:LayoutEdge_Top ofView:self.myLabel withInset:0]];
        [self addConstraint:[self.inletsStackView pinEdge:LayoutEdge_Left toSuperviewEdge:LayoutEdge_Left]];
        self.inletStackRightEdge = [self.inletsStackView pinEdge:LayoutEdge_Right toSuperviewEdge:LayoutEdge_Right];
        if ( self.inletViews.count > 1 ) {
            [self addConstraint:self.inletStackRightEdge];
        }
        [self addConstraint:[self pinEdge:LayoutEdge_Top toEdge:LayoutEdge_Top ofView:self.inletsStackView withInset:0]];
    }
    
    if ( self.outletViews ) {
        self.outletsStackView = [[UIStackView alloc]initWithArrangedSubviews:self.outletViews];
        self.outletsStackView.translatesAutoresizingMaskIntoConstraints = NO;
        self.outletsStackView.axis = UILayoutConstraintAxisHorizontal;
        self.outletsStackView.distribution = UIStackViewDistributionEqualSpacing;
        self.outletsStackView.spacing = kDefaultPortViewSpacing;
        [self addSubview:self.outletsStackView];
        [self addConstraint:[self.outletsStackView pinEdge:LayoutEdge_Top toEdge:LayoutEdge_Bottom ofView:self.myLabel withInset:0]];
        [self addConstraint:[self.outletsStackView pinEdge:LayoutEdge_Left toSuperviewEdge:LayoutEdge_Left]];
        self.outletStackRightEdge = [self.outletsStackView pinEdge:LayoutEdge_Right toSuperviewEdge:LayoutEdge_Right];
        if ( self.outletViews.count > 1 ) {
            [self addConstraint:self.outletStackRightEdge];
        }
        [self addConstraint:[self pinEdge:LayoutEdge_Bottom toEdge:LayoutEdge_Bottom ofView:self.outletsStackView withInset:0]];
    }
    [self updateAppearanceAnimated:NO];
}

- (void)didMoveToSuperview
{
    _myPosition = CGPointZero;
    self.centerXConstraint = [self alignCenterYToSuperOffset:0.0];
    self.centerYConstraint = [self alignCenterXToSuperOffset:0.0];
}

- (void)setPosition:(CGPoint)position
{
    _myPosition = position;
    self.centerXConstraint.constant = position.x;
    self.centerYConstraint.constant = position.y;
    [self.superview layoutIfNeeded];
}

- (CGPoint)getPosition
{
    return self.myPosition;
}

- (NSArray *)positionConstraints
{
    return @[self.centerXConstraint,self.centerYConstraint];
}

- (void)setTitle:(NSString *)title
{
    NSString *oldTitle = _myTitleText;
    _myTitleText = title;
    if ( ![title isEqualToString:oldTitle] ) {
        [self updateAppearanceAnimated:YES];
    }
}

- (void)setSelected:(BOOL)selected
{
    BOOL wasSelected = selected;
    _selected = selected;
    BOOL animate = NO;
    if ( _selected != wasSelected ) {
        animate = YES;
    }
    
    [self updateAppearanceAnimated:animate];
}

- (void)updateAppearanceAnimated:(BOOL)animated
{
    if ( self.selected ) {
        
        self.myFillColor = self.selectedFillColor;
        self.myBorderColor = self.selectedBorderColor;
        self.myTextColor = self.selectedTextColor;
        
    }else{
        
        self.myFillColor = self.defaultFillColor;
        self.myBorderColor = self.defaultBorderColor;
        self.myTextColor = self.defaultTextColor;
    }
    
    [self calculateSpacingAndContentSize];
    
    self.inletsStackView.spacing = self.myMinimumSpacing;
    self.outletsStackView.spacing = self.myMinimumSpacing;
    
    if ( !animated ) {
        self.backgroundColor = self.myFillColor;
        self.layer.borderColor = self.myBorderColor.CGColor;
        self.layer.borderWidth = 1.0;
        self.myLabel.textColor = self.myTextColor;
        self.myLabel.text = self.myTitleText;
        [self.myLabel sizeToFit];
        [self layoutIfNeeded];
        return;
    }
    
    __weak BbBoxView *weakself = self;
    [UIView animateWithDuration:0.2 animations:^{
        weakself.backgroundColor = weakself.myFillColor;
        weakself.layer.borderColor = weakself.myBorderColor.CGColor;
        weakself.layer.borderWidth = 1.0;
        weakself.myLabel.textColor = weakself.myTextColor;
        weakself.myLabel.text = weakself.myTitleText;
        [weakself.myLabel sizeToFit];
        [weakself layoutIfNeeded];
    }];
    
}

- (void)calculateSpacingAndContentSize
{
    CGSize labelSize = [BbBoxView sizeForText:self.myTitleText attributes:[self myLabelAttributes]];
    CGSize inletStackSize = [BbBoxView sizeForPortViews:self.inletViews minimumSpacing:kDefaultPortViewSpacing];
    CGSize outletStackSize = [BbBoxView sizeForPortViews:self.outletViews minimumSpacing:kDefaultPortViewSpacing];
    
    CGSize size;
    size.height = labelSize.height+inletStackSize.height+outletStackSize.height;
    CGFloat maxStackWidth = ( inletStackSize.width >= outletStackSize.width ) ? ( inletStackSize.width ) : ( outletStackSize.width );
    CGFloat maxLabelWidth = labelSize.width + [BbPortView defaultPortViewSize].width * 2;
    size.width = ( maxStackWidth >= maxLabelWidth ) ? ( maxStackWidth ) : ( maxLabelWidth );
    self.myContentSize = size;
    
    if ( maxStackWidth >= maxLabelWidth ) {
        self.myMinimumSpacing = kDefaultPortViewSpacing;
    }else{
        
        NSUInteger maxPortCt = ( self.inletViews.count >= self.outletViews.count ) ? ( self.inletViews.count ) : ( self.outletViews.count );
        if ( maxPortCt <= 1 ) {
            self.myMinimumSpacing = kDefaultPortViewSpacing;
        }else{
            CGFloat ct = (CGFloat)maxPortCt;
            CGFloat width = [BbPortView defaultPortViewSize].width;
            self.myMinimumSpacing = round((maxLabelWidth - ( ct * width ))/( ct - 1.0 ));
        }
    }
}

+ (NSArray *)makeInletViews:(NSUInteger)numIn
{
    if ( !numIn ) {
        return nil;
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:numIn];
    for (NSUInteger i = 0; i < numIn ; i ++ ) {
        BbInletView *inletView = [BbInletView new];
        inletView.tag = i;
        [array addObject:inletView];
    }
    
    return array;
}

+ (NSArray *)makeOutletViews:(NSUInteger)numOut
{
    if ( !numOut ) {
        return nil;
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:numOut];
    for (NSUInteger i = 0; i < numOut ; i ++ ) {
        BbOutletView *outletView = [BbOutletView new];
        outletView.tag = i;
        [array addObject:outletView];
    }
    
    return array;
}

- (CGSize)intrinsicContentSize
{
    return self.myContentSize;
}

- (NSDictionary *)myLabelAttributes
{
    return @{NSFontAttributeName:self.myLabel.font};
}

+ (CGSize)sizeForText:(NSString *)text attributes:(NSDictionary *)attributes
{
    return [text sizeWithAttributes:attributes];
}

+ (CGSize)sizeForPortViews:(NSArray *)portViews minimumSpacing:(CGFloat)minimumSpacing
{
    CGSize size = [BbPortView defaultPortViewSize];
    size.width *= (CGFloat)portViews.count;
    size.width += (CGFloat)(portViews.count - 1) * minimumSpacing;
    return size;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
