//
//  ViewController.m
//  BINPageScrollView
//
//  Created by BIN on 15/10/22.
//  Copyright © 2015年 BIN. All rights reserved.
//

#import "ViewController.h"
#import "BINPageScrollView.h"

@interface ViewController ()<BINPageScrollViewDataSource,BINPageScrollViewDelegate>

@property(nonatomic,weak) BINPageScrollView * pageScrollVoew;

@property(nonatomic,strong) NSArray * images;

@end

@implementation ViewController

-(NSArray *)images{
    if(!_images){
        _images = @[@"1",@"2",@"3",@"4",@"5",@"6"];
    }
    return _images;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    BINPageScrollView * pageScrollView = [[BINPageScrollView alloc] initWithFrame:(CGRectMake(0, 100, self.view.frame.size.width, 185))];
    pageScrollView.delegate = self;
    pageScrollView.dataSource = self;
    pageScrollView.cycleScrollEnabled = YES;
    pageScrollView.pageIndicatorTintColor = [UIColor yellowColor];
    pageScrollView.currentPageIndicatorTintColor = [UIColor redColor];
    self.pageScrollVoew = pageScrollView;
    
    [self.view addSubview:_pageScrollVoew];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - BINPageScrollViewDataSource

-(NSUInteger)numberOfCellsInPageScrollView:(BINPageScrollView *)pageScrollView{
    return self.images.count;
}

-(BINPageScrollViewCell*)pageScrollView:(BINPageScrollView *)pageScrollView cellForIndex:(NSUInteger)index{
    static NSString * ID = @"Cell";
    
    BINPageScrollViewCell * cell = [pageScrollView dequeueReusableCellWithIdentifier:ID];
    
    if(!cell){
        cell = [[BINPageScrollViewCell alloc] initWithReuseIdentifier:ID];
        cell.frame = CGRectMake(0, 0, pageScrollView.frame.size.width, pageScrollView.frame.size.height);
        UIImageView * backgroundImage = [[UIImageView alloc] init];
        
        backgroundImage.frame = cell.bounds;
        backgroundImage.tag = -100;
        
        [cell addSubview:backgroundImage];
    }
    
    UIImageView * backgroundImage = (UIImageView*) [cell viewWithTag:-100];
    
    backgroundImage.image = [UIImage imageNamed:self.images[index]];
    
    return cell;
}

-(NSTimeInterval)timeIntervalOfAutoScrollForPageScrollView:(BINPageScrollView *)pageScrollView{
    return 2.5f;
}


#pragma mark - BINPageScrollViewDelegate

-(void)pageScrollView:(BINPageScrollView *)pageScrollView didEndDeceleratingAtIndex:(NSUInteger)index{
    NSLog(@"didEndDeceleratingAtIndex");
}

-(void)pageScrollView:(BINPageScrollView *)pageScrollView didSelectPageAtIndex:(NSUInteger)index{
    NSLog(@"didSelectPageAtIndex");
}
@end
