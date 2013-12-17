//
//  WUDemoKeyboardBuilder.m
//  WUEmoticonsKeyboardDemo
//
//  Created by YuAo on 7/20/13.
//  Copyright (c) 2013 YuAo. All rights reserved.
//

#import "WUDemoKeyboardBuilder.h"
#import "WUDemoKeyboardTextKeyCell.h"
#import "WUDemoKeyboardPressedCellPopupView.h"

@implementation WUDemoKeyboardBuilder

+ (WUEmoticonsKeyboard *)sharedEmoticonsKeyboard {
    static WUEmoticonsKeyboard *_sharedEmoticonsKeyboard;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //create a keyboard of default size
        WUEmoticonsKeyboard *keyboard = [WUEmoticonsKeyboard keyboard];
        
        //Icon keys
        NSArray *imageKeys = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"emoji" ofType:@"plist"]];
        
        NSMutableArray *imageKeyItems = [NSMutableArray array];
        for (NSDictionary *imageDic in imageKeys) {
            WUEmoticonsKeyboardKeyItem *keyItem = [[WUEmoticonsKeyboardKeyItem alloc] init];
            keyItem.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",imageDic[@"1"]]];
            keyItem.textToInput = [NSString stringWithFormat:@"%@",imageDic[@"1"]];
            [imageKeyItems addObject:keyItem];
        }
        
        NSMutableArray *groupsArray = [NSMutableArray array];
        for (int i  = 0; i < [imageKeys count]; i+=141) {
            WUEmoticonsKeyboardKeyItemGroup *imageIconsGroup = [[WUEmoticonsKeyboardKeyItemGroup alloc] init];
            imageIconsGroup.keyItems = [imageKeyItems subarrayWithRange:NSMakeRange(i, 141)];
            imageIconsGroup.image = [(WUEmoticonsKeyboardKeyItem *)imageKeyItems[i] image];
            //imageIconsGroup2.selectedImage = [UIImage imageNamed:@"keyboard_emotion_selected"];
            [groupsArray addObject:imageIconsGroup];
        }
        
        //Set keyItemGroups
        keyboard.keyItemGroups = [[[NSArray arrayWithArray:groupsArray] reverseObjectEnumerator] allObjects];
        
        //Setup cell popup view
        [keyboard setKeyItemGroupPressedKeyCellChangedBlock:^(WUEmoticonsKeyboardKeyItemGroup *keyItemGroup, WUEmoticonsKeyboardKeyCell *fromCell, WUEmoticonsKeyboardKeyCell *toCell) {
            [WUDemoKeyboardBuilder sharedEmotionsKeyboardKeyItemGroup:keyItemGroup pressedKeyCellChangedFromCell:fromCell toCell:toCell];
        }];
        //Custom utility keys
       // [keyboard setImage:[UIImage imageNamed:@"keyboard_switch"] forButton:WUEmoticonsKeyboardButtonKeyboardSwitch state:UIControlStateNormal];
        [keyboard setImage:[UIImage imageNamed:@"keyboard_del"] forButton:WUEmoticonsKeyboardButtonBackspace state:UIControlStateNormal];
       // [keyboard setImage:[UIImage imageNamed:@"keyboard_switch_pressed"] forButton:WUEmoticonsKeyboardButtonKeyboardSwitch state:UIControlStateHighlighted];
        [keyboard setImage:[UIImage imageNamed:@"keyboard_del_pressed"] forButton:WUEmoticonsKeyboardButtonBackspace state:UIControlStateHighlighted];
        
        //Keyboard background
        [keyboard setBackgroundImage:[[UIImage imageNamed:@"keyboard_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)]];
        
        //SegmentedControl
        [[UISegmentedControl appearanceWhenContainedIn:[WUEmoticonsKeyboard class], nil] setBackgroundImage:[[UIImage imageNamed:@"keyboard_segment_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [[UISegmentedControl appearanceWhenContainedIn:[WUEmoticonsKeyboard class], nil] setBackgroundImage:[[UIImage imageNamed:@"keyboard_segment_selected"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        [[UISegmentedControl appearanceWhenContainedIn:[WUEmoticonsKeyboard class], nil] setDividerImage:[UIImage imageNamed:@"keyboard_segment_normal_selected"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        [[UISegmentedControl appearanceWhenContainedIn:[WUEmoticonsKeyboard class], nil] setDividerImage:[UIImage imageNamed:@"keyboard_segment_selected_normal"] forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
                
        _sharedEmoticonsKeyboard = keyboard;
    });
    return _sharedEmoticonsKeyboard;
}

+ (void)sharedEmotionsKeyboardKeyItemGroup:(WUEmoticonsKeyboardKeyItemGroup *)keyItemGroup
             pressedKeyCellChangedFromCell:(WUEmoticonsKeyboardKeyCell *)fromCell
                                    toCell:(WUEmoticonsKeyboardKeyCell *)toCell
{
    static WUDemoKeyboardPressedCellPopupView *pressedKeyCellPopupView;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pressedKeyCellPopupView = [[WUDemoKeyboardPressedCellPopupView alloc] initWithFrame:CGRectMake(0, 0, 83, 110)];
        pressedKeyCellPopupView.hidden = YES;
        [[self sharedEmoticonsKeyboard] addSubview:pressedKeyCellPopupView];
    });
    
    if ([[self sharedEmoticonsKeyboard].keyItemGroups indexOfObject:keyItemGroup] == 0) {
        [[self sharedEmoticonsKeyboard] bringSubviewToFront:pressedKeyCellPopupView];
        if (toCell) {
            pressedKeyCellPopupView.keyItem = toCell.keyItem;
            pressedKeyCellPopupView.hidden = NO;
            CGRect frame = [[self sharedEmoticonsKeyboard] convertRect:toCell.bounds fromView:toCell];
            pressedKeyCellPopupView.center = CGPointMake(CGRectGetMidX(frame), CGRectGetMaxY(frame)-CGRectGetHeight(pressedKeyCellPopupView.frame)/2);
        }else{
            pressedKeyCellPopupView.hidden = YES;
        }
    }
}

@end
