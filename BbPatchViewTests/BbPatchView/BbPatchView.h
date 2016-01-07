//
//  BbPatchView.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 1/6/16.
//  Copyright © 2016 birdSound LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BbPatchViewEditState) {
    BbPatchViewEditState_Default    =   0,
    BbPatchViewEditState_Editing    =   1,
    BbPatchViewEditState_Selected   =   2,
    BbPatchViewEditState_Copied     =   3
};

typedef NS_ENUM(NSInteger, BbPatchViewType){
    BbPatchViewType_Unknown         =   -1,
    BbPatchViewType_Patch           =   0,
    BbPatchViewType_Object          =   1,
    BbPatchViewType_Inlet           =   2,
    BbPatchViewType_Outlet          =   3,
    BbPatchViewType_Message         =   4,
    BbPatchViewType_Bang            =   5,
    BbPatchViewType_PatchInlet      =   6,
    BbPatchViewType_PatchOutlet     =   7
};


@protocol BbPatchViewDelegate <NSObject>

- (void)patchView:(id)sender setScrollViewShouldBegin:(BOOL)shouldBegin;
- (void)patchView:(id)sender setScrollViewShouldCancel:(BOOL)shouldCancel;

@end

@class BbBoxView;

@interface BbPatchView : UIView

@property (nonatomic)               id<BbPatchViewDelegate>         delegate;

@property (nonatomic)               BbPatchViewEditState            *editState;
@property (nonatomic,getter=isOpen) BOOL                            open;

- (void)addBoxView:(BbBoxView *)boxView atPoint:(CGPoint)point;

@end
