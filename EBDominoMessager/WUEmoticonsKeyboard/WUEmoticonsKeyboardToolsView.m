//
//  WUEmoticonsKeyboardToolsView.m
//  WeicoUI
//
//  Created by YuAo on 1/25/13.
//  Copyright (c) 2013 微酷奥(北京)科技有限公司. All rights reserved.
//

#import "WUEmoticonsKeyboardToolsView.h"
#import <SwipeView.h>

@interface WUEmoticonsKeyboardToolsView ()<SwipeViewDelegate, SwipeViewDataSource>

@property (nonatomic,weak,readwrite) UIButton           *keyboardSwitchButton;
@property (nonatomic,weak,readwrite) UIButton           *backspaceButton;
@property (nonatomic,weak)           UISegmentedControl *segmentedControl;
@property (nonatomic, strong) SwipeView *swipeView;
@property (nonatomic, copy) NSArray *keyItems;
@end

@implementation WUEmoticonsKeyboardToolsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIButton *keyboardSwitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        keyboardSwitchButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        [keyboardSwitchButton addTarget:self action:@selector(keyboardSwitchButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
       // [self addSubview:keyboardSwitchButton];
        self.keyboardSwitchButton = keyboardSwitchButton;
        
        UIButton *backspaceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backspaceButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        [backspaceButton addTarget:self action:@selector(backspaceButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:backspaceButton];
        self.backspaceButton = backspaceButton;
        
        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithFrame:CGRectZero];
        segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:segmentedControl];
        self.segmentedControl = segmentedControl;
       // self.segmentedControl.hidden = YES;
        
        _swipeView = [[SwipeView alloc] initWithFrame:CGRectMake(0, 0, 300, 30)];
        //configure swipe view
        _swipeView.alignment = SwipeViewAlignmentCenter;
        _swipeView.pagingEnabled = YES;
        _swipeView.wrapEnabled = NO;
        _swipeView.itemsPerPage = 6;
        _swipeView.scrollEnabled = NO;
        _swipeView.truncateFinalPage = YES;
        _swipeView.delegate = self;
        _swipeView.dataSource = self;
        [self addSubview:_swipeView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
   // CGSize keyboardSwitchButtonSize = [self.keyboardSwitchButton sizeThatFits:self.bounds.size];
    CGSize backspaceButtonSize = [self.backspaceButton sizeThatFits:self.bounds.size];
    
   // self.keyboardSwitchButton.frame = (CGRect){CGPointZero,keyboardSwitchButtonSize};
    self.backspaceButton.frame = (CGRect){ {CGRectGetWidth(self.bounds) - backspaceButtonSize.width, 0} ,backspaceButtonSize};
   // self.segmentedControl.frame =
    [_swipeView setFrame:CGRectMake(-20, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
}

- (void)setKeyItemGroups:(NSArray *)keyItemGroups {
    _keyItemGroups = keyItemGroups;
    [_swipeView reloadData];
    [self categoryClicked:0];
//    [self.segmentedControl removeAllSegments];
 //   [self.keyItemGroups enumerateObjectsUsingBlock:^(WUEmoticonsKeyboardKeyItemGroup *obj, NSUInteger idx, BOOL *stop) {
//        if (obj.image) {
//            [self.segmentedControl insertSegmentWithImage:obj.image atIndex:self.segmentedControl.numberOfSegments animated:NO];
//        }else{
//            [self.segmentedControl insertSegmentWithTitle:obj.title atIndex:self.segmentedControl.numberOfSegments animated:NO];
//        }
//    }];
//    if (self.segmentedControl.numberOfSegments) {
//        self.segmentedControl.selectedSegmentIndex = 0;
//        [self segmentedControlValueChanged:self.segmentedControl];
//    }
}

- (void)segmentedControlValueChanged:(UISegmentedControl *)sender {
    [self.keyItemGroups enumerateObjectsUsingBlock:^(WUEmoticonsKeyboardKeyItemGroup *obj, NSUInteger idx, BOOL *stop) {
        if (obj.image) {
            if (obj.selectedImage && (NSInteger)idx == self.segmentedControl.selectedSegmentIndex) {
                [self.segmentedControl setImage:obj.selectedImage forSegmentAtIndex:idx];
            } else {
                [self.segmentedControl setImage:obj.image forSegmentAtIndex:idx];                
            }
        } else {
            [self.segmentedControl setTitle:obj.title forSegmentAtIndex:idx];
        }
    }];
    if (self.keyItemGroupSelectedBlock) {
        WUEmoticonsKeyboardKeyItemGroup *selectedKeyItemGroup = [self.keyItemGroups objectAtIndex:self.segmentedControl.selectedSegmentIndex];
        self.keyItemGroupSelectedBlock(selectedKeyItemGroup);
    }
}

- (void)categoryClicked:(NSInteger)index
{
//    [self.keyItemGroups enumerateObjectsUsingBlock:^(WUEmoticonsKeyboardKeyItemGroup *obj, NSUInteger idx, BOOL *stop) {
//        if (obj.image) {
//            if (obj.selectedImage && (NSInteger)idx == self.segmentedControl.selectedSegmentIndex) {
//                [self.segmentedControl setImage:obj.selectedImage forSegmentAtIndex:idx];
//            } else {
//                [self.segmentedControl setImage:obj.image forSegmentAtIndex:idx];
//            }
//        } else {
//            [self.segmentedControl setTitle:obj.title forSegmentAtIndex:idx];
//        }
//    }];
    if (self.keyItemGroupSelectedBlock) {
        WUEmoticonsKeyboardKeyItemGroup *selectedKeyItemGroup = [self.keyItemGroups objectAtIndex:index];
        self.keyItemGroupSelectedBlock(selectedKeyItemGroup);
    }
}

- (void)keyboardSwitchButtonTapped:(UIButton *)sender {
    if (self.keyboardSwitchButtonTappedBlock) {
        self.keyboardSwitchButtonTappedBlock();
    }
}

- (void)backspaceButtonTapped:(UIButton *)sender {
    if (self.backspaceButtonTappedBlock) {
        self.backspaceButtonTappedBlock();
    }
}

- (NSInteger)numberOfItemsInSwipeView:(__unused SwipeView *)swipeView
{
    return [_keyItemGroups count];
}

- (UIView *)swipeView:(__unused SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UIImageView *imageView = (UIImageView *)view;
    
    //create or reuse view
    if (view == nil)
    {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
        view = imageView;
    }
    
    imageView.image = [(WUEmoticonsKeyboardKeyItemGroup *)_keyItemGroups[index] image];
    
    view.layer.borderColor = UIColor.grayColor.CGColor;
    view.layer.borderWidth = 0.5;
    //return view
    return view;
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{

}

- (void)swipeView:(__unused SwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"Selected item at index %i", index);
    [self categoryClicked:index];
}

@end
