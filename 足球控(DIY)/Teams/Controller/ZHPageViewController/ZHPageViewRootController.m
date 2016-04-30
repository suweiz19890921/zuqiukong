//
//  ZHRootViewController.m
//  shareCode
//
//  Created by qianfeng on 15/12/17.
//  Copyright (c) 2015年 叶无道. All rights reserved.
//

#import "ZHPageViewRootController.h"
#import "UIView+Extension.h"
#define vcArray @[@"ZHStatusViewController",@"ZHSeasonViewController",@"ZHParkViewController",@"ZHPlayerViewController"]
#define vcTitleArray @[@"动态",@"赛季",@"游乐园",@"球员"]
#define vcNumber vcArray.count
@interface ZHPageViewRootController ()<ZHPageSliderDelegate,UIScrollViewDelegate>
@end

@implementation ZHPageViewRootController
{
    UIScrollView *_scrollView;
    ZHPageSlider *_pageSlider;
    CGFloat _originX;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
}


//移动到母控制器上时再进行子控件的安装
- (void)willMoveToParentViewController:(UIViewController *)parent
{
    /**
     *  这个方法是自己被添加到父控件的时候会调用的方法，此时frame已经确定
     */
 
    [self setupTopPageSlider];
    [self setupScrollView];
    [self addChildViewControllers];
    
}
#pragma mark setupPageView
//创建scrollView
- (void)setupScrollView
{
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    _scrollView = scrollView;
    _scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    scrollView.bounces = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.y  =  _pageSlider.height;
    scrollView.height = self.view.height - _pageSlider.height + 49;
    
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width * vcNumber, self.view.height);
    [self.view addSubview:scrollView];
}
//创建子控制器
- (void)addChildViewControllers
{
    for (int i = 0; i < vcNumber; i++) {
        Class clazz = NSClassFromString(vcArray[i]);
        UIViewController *viewC = [[clazz alloc]init];
        [self addChildViewController:viewC];
        //设置view的frame 并且加入视图
        viewC.view.x = self.view.width * i;
        viewC.view.height = self.view.height - _pageSlider.height;
        [_scrollView addSubview:viewC.view];
    }
}

//创建顶部的pageSlider
- (void)setupTopPageSlider
{
    /**
     *  这是球队页面中 一个透明的 scrollview
     */
    ZHPageSlider *pageControl = [ZHPageSlider pageSlider];
    pageControl.pageDelegate = self;
    _pageSlider = pageControl;
    pageControl.pageNumber = vcNumber;
    pageControl.titleArray = vcTitleArray;
    [self.view addSubview:pageControl];
}

#pragma mark ZHPageSlider的代理
//Slider的代理方法，Slider按钮点击的时候，scrollview的contentOffset跟着改变
- (void)ZHPageSliderTitleButtonDidClicked:(ZHPageSlider *)pageSlider atIndex:(NSUInteger)index WithButton:(UIButton *)button
{
    [UIView animateWithDuration:0.5 animations:^{
        pageSlider.selectedIndex = index;
        
        _scrollView.contentOffset = CGPointMake(_scrollView.width * index, 0);
    }];
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _scrollView) {
        [UIView animateWithDuration:0.5 animations:^{
            _pageSlider.selectedIndex = scrollView.contentOffset.x / _scrollView.width;
        }];
    }
}

-(void)didReceiveMemoryWarning
{
     NSLog(@"%s",__func__);
    for (UIViewController *vc in self.childViewControllers) {
        [vc removeFromParentViewController];
    }
}

#pragma mark 刷新子视图数据的方法
- (void)reloadData
{
    [self.childViewControllers makeObjectsPerformSelector:@selector(reloadTableViewData)];
}
@end
