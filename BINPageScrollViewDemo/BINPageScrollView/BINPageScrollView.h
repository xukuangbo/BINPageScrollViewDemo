//
//  BINPageScrollView.h
//  BINPageScrollViewDemo
//
//  Created by BIN on 15/10/22.
//  Copyright © 2015年 BIN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BINPageScrollView;
@class BINPageScrollViewCell;

@protocol BINPageScrollViewDelegate <NSObject>

@optional

- (void)pageScrollView:(BINPageScrollView *)pageScrollView didEndDeceleratingAtIndex:(NSUInteger)index;

- (void)pageScrollView:(BINPageScrollView *)pageScrollView didSelectPageAtIndex:(NSUInteger)index;

@end


@protocol BINPageScrollViewDataSource <NSObject>

@required

- (NSUInteger)numberOfCellsInPageScrollView:(BINPageScrollView *)pageScrollView;

- (BINPageScrollViewCell *)pageScrollView:(BINPageScrollView *)pageScrollView cellForIndex:(NSUInteger)index;

@optional

- (NSTimeInterval)timeIntervalOfAutoScrollForPageScrollView:(BINPageScrollView *)pageScrollView;

@end

@interface BINPageScrollViewCell : UIView

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end

@interface BINPageScrollView : UIView

- (id)initWithFrame:(CGRect)frame;

@property (weak, nonatomic) id <BINPageScrollViewDataSource> dataSource;
@property (weak, nonatomic) id <BINPageScrollViewDelegate>   delegate;
@property (assign, nonatomic) BOOL cycleScrollEnabled; //default NO;

- (void)reloadData;

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;

@end

