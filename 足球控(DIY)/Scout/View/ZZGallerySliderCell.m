//
//  Cell.m
//  newCollectionView
//
//  Created by chester on 14-2-20.
//  Copyright (c) 2014年 chester. All rights reserved.
//

#import "ZZGallerySliderCell.h"
#import "macro.h"
#import "ZHPersonStatisView.h"
@interface ZZGallerySliderCell()
{
    BOOL hasLayout;
}

@property(nonatomic, strong) NSURL *currentBackURL;
@property(nonatomic) NSUInteger cellIndex;

@end

@implementation ZZGallerySliderCell


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        hasLayout = NO;
        self.clipsToBounds = YES;
        //根据当前CELL所在屏幕的不同位置，初始化IMAGEVIEW的相对位置，为了配合滚动时的IMAGEVIEW偏移动画
        //(screen_y-attributes.frame.origin.y)/568*80
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, IMAGEVIEW_ORIGIN_Y-self.frame.origin.y/568*IMAGEVIEW_MOVE_DISTANCE, CELL_WIDTH, SC_IMAGEVIEW_HEIGHT)];
        self.imageView.contentMode =  UIViewContentModeScaleAspectFill;
        [self addSubview:self.imageView];
        
        self.maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH, 250)];
        self.maskView.backgroundColor = [UIColor blackColor];
        self.maskView.alpha = 0.6;
        [self addSubview:self.maskView];
        
        self.title = [[UILabel alloc] initWithFrame:CGRectMake(0, (CELL_HEIGHT-TITLE_HEIGHT)/2, CELL_WIDTH, TITLE_HEIGHT)];
        self.title.textColor = [UIColor whiteColor];
        self.title.font = [UIFont systemFontOfSize:30];
        self.title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.title];
        self.contentMode = UIViewContentModeCenter;
        self.title.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1);
        self.title.center = self.contentView.center;
        [self.title setBackgroundColor:[UIColor clearColor]];
        
        self.desc = [[UILabel alloc] initWithFrame:CGRectMake(0, (CELL_HEIGHT-TITLE_HEIGHT)/2+30, 300, 0)];
        self.desc.textColor = [UIColor whiteColor];
        self.desc.numberOfLines  = 0;
        self.desc.font = [UIFont boldSystemFontOfSize:15];
        self.desc.alpha = 0;
        self.desc.textAlignment = NSTextAlignmentCenter;
        self.desc.backgroundColor = [UIColor clearColor];
        [self addSubview:self.desc];
        
 #warning 自己添加 副view
        ZHPersonStatisView *subPlayerView = [ZHPersonStatisView view];
        self.subPlayerView = subPlayerView;
        [self addSubview:self.subPlayerView];
        self.subPlayerView.backgroundColor = [UIColor clearColor];
//        self.subPlayerView.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1);
        self.subPlayerView.frame = CGRectMake(0, CELL_HEIGHT+200, 375, 75);
    }
    return self;
}

-(void)revisePositionAtFirstCell
{
    if(self.tag == 1){
        self.desc.frame = CGRectMake(10, 85+60, self.desc.frame.size.width, self.desc.frame.size.height);
        self.title.layer.transform = CATransform3DMakeScale(1, 1, 1);
        
        self.desc.alpha = 0.85;
        self.title.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, self.contentView.center.y);
    }
}

-(void)setIndex:(NSUInteger)index
{
    self.cellIndex = index;
    if (self.cellIndex == 0) {
        
        self.maskView.alpha = 0;
        self.backgroundColor = [UIColor lightGrayColor];
        
    }else if(self.cellIndex == 1){
        
        self.maskView.alpha = 0.2;
        self.backgroundColor = [UIColor blackColor];
        
    }else{
        
        self.maskView.alpha = 0.6;
        self.backgroundColor = [UIColor blackColor];
        
    }
    [self setImageViewPostion];
}
#warning 给副view添加数据
//添加副view
-(void)setPlayerView:(ZHPerson *)player
{
    //给他传递数据
    self.subPlayerView.person = player;
}
-(void)setImageViewPostion
{
    if (self.imageView) {
        self.imageView.frame = CGRectMake(0, IMAGEVIEW_ORIGIN_Y-self.frame.origin.y/568*IMAGEVIEW_MOVE_DISTANCE, CELL_WIDTH, SC_IMAGEVIEW_HEIGHT);
    }
}

-(void)setNameLabel:(NSString *)string
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:string];
    self.title.attributedText = str;
}

-(void)setDescLabel:(NSString *)string
{
    if(string == nil || [string isEqualToString:@""]){
        return;
    }
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:string];
    self.desc.attributedText = str;
    CGSize size = [string boundingRectWithSize:CGSizeMake(300, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15]} context:nil].size;
    self.desc.frame = CGRectMake(10, self.desc.frame.origin.y, 300, size.height);
    
}

/**
 *  重置属性
 */

-(void)reset
{
    self.imageView.image = nil;
    self.title.text = @"";
    self.desc.text = @"";
}

-(void)dealloc
{
    self.imageView = nil;
    self.maskView = nil;
    self.title = nil;
}

@end
