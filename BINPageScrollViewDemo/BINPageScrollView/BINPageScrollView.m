//
//  BINPageScrollView.m
//  BINPageScrollViewDemo
//
//  Created by BIN on 15/10/22.
//  Copyright © 2015年 BIN. All rights reserved.
//

#import "BINPageScrollView.h"


@interface BINPageScrollView () <UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    NSTimeInterval          _scrollTime;
    
    UIScrollView            *_scrollView;
    NSMutableDictionary     *_reusableCellDict;
    NSMutableArray          *_visibleCells;
    
    NSInteger               _totalCount;
}

@property (assign, nonatomic) BOOL timerShouldInvoke;
@property (strong, nonatomic) NSTimer *timer;

- (NSInteger)getDataIndex;

@end

@interface BINPageScrollViewCell ()

@property (strong, nonatomic) NSString *reuseIdentifie;
@property (assign, nonatomic) NSUInteger index;
@property (weak, nonatomic) BINPageScrollView *pageScrollView;

@end


/********************************************************************************/
@implementation BINPageScrollViewCell : UIView

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifie
{
    if (self = [super init])
    {
        self.reuseIdentifie = reuseIdentifie;
        self.clipsToBounds = YES;
    }
    return self;
}

#pragma mark - touchs

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    self.pageScrollView.timerShouldInvoke = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if ([self.pageScrollView.delegate respondsToSelector:@selector(pageScrollView:didSelectPageAtIndex:)])
    {
        [self.pageScrollView.delegate pageScrollView:self.pageScrollView didSelectPageAtIndex:[self.pageScrollView getDataIndex]];
    }
    self.pageScrollView.timerShouldInvoke = YES;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    self.pageScrollView.timerShouldInvoke = YES;
}


@end
/********************************************************************************/



/********************************************************************************/
@implementation BINPageScrollView

- (void)dealloc
{
    _scrollView.delegate = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _scrollTime = 0.0;
        self.backgroundColor = [UIColor clearColor];
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self addSubview:_scrollView];
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.contentOffset = CGPointMake(0, 0);
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        _reusableCellDict = [[NSMutableDictionary alloc] initWithCapacity:0];
        _visibleCells = [[NSMutableArray alloc] initWithCapacity:0];
        
        _timerShouldInvoke = YES;
    }
    return self;
}

#pragma mark - override Method

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat originalWidth = 0;
    for (BINPageScrollViewCell *cell in _scrollView.subviews) {
        originalWidth = cell.frame.size.width;
        cell.frame = CGRectMake(cell.index * _scrollView.frame.size.width, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    }
    if (originalWidth > 0) {
        _scrollView.contentOffset = CGPointMake(_scrollView.contentOffset.x / originalWidth * self.frame.size.width, 0);
    }
    
    if (_cycleScrollEnabled)
    {
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * (_totalCount + 2), _scrollView.frame.size.height);
    }
    else
    {
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * _totalCount, _scrollView.frame.size.height);
    }
    
}

- (void)removeFromSuperview
{
    if (self.timer && [self.timer isValid])
    {
        [self.timer invalidate];
        self.timer = nil;
    }
    [super removeFromSuperview];
}

- (void)setCycleScrollEnabled:(BOOL)cycleScrollEnabled
{
    if (_cycleScrollEnabled != cycleScrollEnabled)
    {
        _cycleScrollEnabled = cycleScrollEnabled;
        [self reloaBINata];
    }
}

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat contentOffSetX = scrollView.contentOffset.x;
    
    if (_cycleScrollEnabled)
    {
        if (contentOffSetX <= 0) {
            _scrollView.contentOffset = CGPointMake(_scrollView.frame.size.width * _totalCount + contentOffSetX, 0);
            return;
        }
        else if (contentOffSetX >= _scrollView.frame.size.width * (_totalCount + 1))
        {
            _scrollView.contentOffset = CGPointMake(_scrollView.frame.size.width + (int)contentOffSetX % (int)_scrollView.frame.size.width, 0);
            return;
        }
    }
    
    NSMutableArray *needReusableCells = [NSMutableArray array];
    for (BINPageScrollViewCell *cell in _visibleCells)
    {
        if (CGRectGetMaxX(cell.frame) < contentOffSetX || cell.frame.origin.x > contentOffSetX + scrollView.frame.size.width)
        {
            [needReusableCells addObject:cell];
        }
    }
    if (needReusableCells.count > 0) {
        for (BINPageScrollViewCell *cell in needReusableCells) {
            [self reusableCell:cell];
        }
    }
    
    NSInteger index = (int)contentOffSetX / scrollView.frame.size.width;
    if (index >= 0) {
        if (![self cellForIndex:index])
        {
            NSInteger dateIndex = index;
            if (_cycleScrollEnabled)
            {
                dateIndex = index == 0 ? _totalCount - 1 : (index == _totalCount + 1 ? 0 : index - 1);
            }
            
            BINPageScrollViewCell *cell = [self.dataSource pageScrollView:self cellForIndex:dateIndex];
            [self aBINCell:cell atIndex:index];
        }
        
        if ((int)_scrollView.contentOffset.x % (int)_scrollView.frame.size.width > 0)
        {
            NSInteger nextIndex = index + 1;
            if (![self cellForIndex:nextIndex])
            {
                NSInteger nextDataIndex = nextIndex;
                if (_cycleScrollEnabled)
                {
                    nextDataIndex = nextIndex == 0 ? _totalCount - 1 : (nextIndex == _totalCount + 1 ? 0 : nextIndex - 1);
                }
                
                if (nextDataIndex > _totalCount - 1) {
                    return;
                }
                BINPageScrollViewCell *cell = [self.dataSource pageScrollView:self cellForIndex:nextDataIndex];
                [self aBINCell:cell atIndex:nextIndex];
            }
        }
    }
}

- (void)scrollViewDidEnBINecelerating:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(pageScrollView:didEndDeceleratingAtIndex:)])
    {
        [self.delegate pageScrollView:self didEndDeceleratingAtIndex:[self getDataIndex]];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.timerShouldInvoke = NO;
}

- (void)scrollViewDidEnBINragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.timerShouldInvoke = YES;
}

- (void)scrollToNextIndex
{
    NSInteger index = (int)_scrollView.contentOffset.x / _scrollView.frame.size.width ;
    NSInteger nextIndex = index + 1;
    if (!_cycleScrollEnabled && index == _totalCount - 1)
    {
        nextIndex = 0;
    }
    
    [_scrollView setContentOffset: CGPointMake(_scrollView.frame.size.width * nextIndex, 0) animated:YES];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(pageScrollView:didEndDeceleratingAtIndex:)])
    {
        [self.delegate pageScrollView:self didEndDeceleratingAtIndex:[self getDataIndex]];
    }
}

#pragma mark - public instant Method


- (void)reloaBINata
{
    if (!self.dataSource)
    {
        return;
    }
    
    if (_cycleScrollEnabled && _scrollView.contentOffset.x == 0) {
        _scrollView.contentOffset = CGPointMake(_scrollView.frame.size.width, 0);
    }
    
    if ([self.dataSource respondsToSelector:@selector(timeIntervalOfAutoScrollForPageScrollView:)])
    {
        _scrollTime = [self.dataSource timeIntervalOfAutoScrollForPageScrollView:self];
        if (_scrollTime > 0)
        {
            [self fireTimer:YES];
        }
    }
    
    for (BINPageScrollViewCell *cell in _scrollView.subviews)
    {
        if ([cell isKindOfClass:[BINPageScrollViewCell class]]) {
            [self reusableCell:cell];
        }
    }
    
    
    _totalCount = [self.dataSource numberOfCellsInPageScrollView:self];
    if (_totalCount > 0) {
        if (_cycleScrollEnabled)
        {
            _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * (_totalCount + 2), _scrollView.frame.size.height);
        }
        else
        {
            _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * _totalCount, _scrollView.frame.size.height);
        }
        
        
        NSInteger index = (int)_scrollView.contentOffset.x / _scrollView.frame.size.width;
        NSInteger dateIndex = index;
        if (_cycleScrollEnabled)
        {
            dateIndex = index == 0 ? _totalCount - 1 : (index == _totalCount + 1 ? 0 : index - 1);
        }
        
        BINPageScrollViewCell *cell = [self.dataSource pageScrollView:self cellForIndex:dateIndex];
        [self aBINCell:cell atIndex:index];
        
        if ((int)_scrollView.contentOffset.x % (int)_scrollView.frame.size.width > 0)
        {
            NSInteger nextIndex = index + 1;
            NSInteger nextDataIndex = nextIndex;
            if (_cycleScrollEnabled)
            {
                nextDataIndex = nextIndex == 0 ? _totalCount - 1 : (nextIndex == _totalCount + 1 ? 0 : nextIndex - 1);
            }
            BINPageScrollViewCell *cell = [self.dataSource pageScrollView:self cellForIndex:nextDataIndex];
            [self aBINCell:cell atIndex:nextIndex];
        }
    }
}

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    NSMutableArray *reusableCellArray = [_reusableCellDict objectForKey:identifier];
    BINPageScrollViewCell *cell = reusableCellArray.lastObject;
    return cell;
}

#pragma mark - support Method

- (void)visibleCell:(BINPageScrollViewCell *)cell
{
    NSMutableArray *reusableCellArray = [_reusableCellDict objectForKey:cell.reuseIdentifie];
    [_visibleCells addObject:cell];
    [reusableCellArray removeObject:cell];
}

- (void)reusableCell:(BINPageScrollViewCell *)cell
{
    NSMutableArray *reusableCellArray = [_reusableCellDict objectForKey:cell.reuseIdentifie];
    if (!reusableCellArray) {
        reusableCellArray = [NSMutableArray arrayWithCapacity:0];
        [_reusableCellDict setObject:reusableCellArray forKey:cell.reuseIdentifie];
    }
    [reusableCellArray addObject:cell];
    [_visibleCells removeObject:cell];
    [cell removeFromSuperview];
}


- (BINPageScrollViewCell *)cellForIndex:(NSUInteger)index
{
    BINPageScrollViewCell *aCell = nil;
    for (BINPageScrollViewCell *cell in _visibleCells)
    {
        if (cell.index == index) {
            aCell = cell;
            break;
        }
    }
    return aCell;
}

- (void)aBINCell:(BINPageScrollViewCell *)cell atIndex:(NSUInteger)index
{
    cell.pageScrollView = self;
    cell.index = index;
    cell.frame = CGRectMake(index * _scrollView.frame.size.width, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    [_scrollView addSubview:cell];
    [self visibleCell:cell];
}

- (NSInteger)getDataIndex
{
    NSInteger index = (int)_scrollView.contentOffset.x / _scrollView.frame.size.width ;
    NSInteger dateIndex = index;
    if (_cycleScrollEnabled)
    {
        dateIndex = index == 0 ? _totalCount - 1 : (index == _totalCount + 1 ? 0 : index - 1);
    }
    
    return dateIndex;
}

#pragma mark - override Method

- (void)setTimerShouldInvoke:(BOOL)timerShouldInvoke
{
    if (_timerShouldInvoke != timerShouldInvoke && _scrollTime > 0)
    {
        _timerShouldInvoke = timerShouldInvoke;
        if (_timerShouldInvoke) {
            [self fireTimer:YES];
        }
        else
        {
            [self fireTimer:NO];
        }
    }
}

#pragma mark - Timer

- (void)fireTimer:(BOOL)isFireTimer
{
    if (!self.timer)
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:_scrollTime
                                                      target:self
                                                    selector:@selector(timerInvoke)
                                                    userInfo:nil
                                                     repeats:YES];
    }
    
    if (isFireTimer)
    {
        [self.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:_scrollTime]];
    }
    else
    {
        [self.timer setFireDate:[NSDate distantFuture]];
    }
}

- (void)timerInvoke
{
    [self scrollToNextIndex];
}

@end
/********************************************************************************/
