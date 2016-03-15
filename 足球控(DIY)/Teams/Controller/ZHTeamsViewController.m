

#import "ZHTeamsViewController.h"
#import "ZHLeftView.h"
#import "UIView+Extension.h"
#import "ZHTeamsTableView.h"
#import "ZHTopView.h"
#import "ZHPageSlider.h"
#import "ZHPageViewRootController.h"
#import "ZHAddFavController.h"
#import "ZHHttpTool.h"
#import "ZHFavourite.h"
#import "MJExtension.h"
#import "ZHNGViewController.h"
#import "ZHMyFavs.h"
#import "FXBlurView.h"
#import "TotalAPI.h"
#import "ZHTrophy.h"
#import "UMSocial.h"
@interface ZHTeamsViewController ()<UMSocialUIDelegate>
@property (nonatomic,strong)UISwipeGestureRecognizer *swipe;
@property (nonatomic,assign,getter=isShowLeftView)BOOL showLeftView;
@property (nonatomic,weak) UIView *hudView;
@end

@implementation ZHTeamsViewController
{
    ZHLeftView *_leftView;
    ZHPageSlider *_pageSlider;
    ZHTopView *_topView;
    UIView *_HUDView;
    ZHPageViewRootController *_pageViewVC;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupLeftView];
    [self setupTopView];
    [self setupPageViewController];
    
}

#pragma mark 创建相关控件
- (void)setupTopView
{
    ZHTopView *topView = [ZHTopView topView];
    _topView = topView;
    [self.view addSubview:topView];
    
    //传递第一次的数据
    topView.selectedTeam = [_leftView.favsArray firstObject];
    self.selectedTeam = topView.selectedTeam;
    //第一次进入没有喜欢的球队就要提醒用户添加球队!!!
    [self remindAddFav];

    //请求锦标数
    [self requestTeamTrophies];
    //并加入单例中
    [ZHMyFavs setSelTeam:topView.selectedTeam];
    //点击左键会调用的block
    __weak typeof(self) weakSelf = self;
    [_topView setLeftButtonClickBlock:^{
        weakSelf.showLeftView = !weakSelf.showLeftView;
        [weakSelf leftViewMove];
        
    }];
    //点击分享会回调
    [_topView setShareButtonClickBlick:^{
        [UMSocialSnsService presentSnsIconSheetView:weakSelf
                                             appKey:@"569b815b67e58eca400007d1"
                                          shareText:@"你要分享的文字"
                                         shareImage:nil
                                    shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToWechatSession,UMShareToEmail,nil]
                                           delegate:weakSelf];
        
    }];
}
- (void)setupPageViewSlider
{
    //顶部滑动条
    ZHPageSlider *pageSlider = [ZHPageSlider pageSlider];
    _pageSlider = pageSlider;
    pageSlider.height = 30;
    pageSlider.y = _topView.height - pageSlider.height;
    pageSlider.titleArray = @[@"动态",@"赛季",@"球员",@"转会"];
    [self.view addSubview:pageSlider];
}

//提醒方法

- (void)remindAddFav
{
   if (!self.selectedTeam)
   {
       UIView *hudView = [[[NSBundle mainBundle]loadNibNamed:@"firstComeView" owner:nil options:nil]lastObject];
       self.hudView = hudView;
       [self.tabBarController.view addSubview:self.hudView];
       UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self     action:@selector(removeHud)];
       [self.hudView addGestureRecognizer:tap];
       NSLog(@"请您添加想要关注的球队");
   }
}
- (void)removeHud
{
    [self.hudView removeFromSuperview];
}
//创建pageViewController
- (void)setupPageViewController
{
    ZHPageViewRootController *rootViewController = [[ZHPageViewRootController alloc]init];
    _pageViewVC = rootViewController;
    rootViewController.view.y = CGRectGetMaxY(_topView.frame) - 40;
    rootViewController.view.width = self.view.width;
    rootViewController.view.height = self.view.height - _topView.height + 40;
    rootViewController.view.backgroundColor = [UIColor clearColor];
    [self addChildViewController:rootViewController];
    [self.view addSubview:rootViewController.view];
    
    //设置回调block
//    rootViewController.didClickCellHandler
}

#pragma mark 左边栏相关的操作
//创建左边栏
- (void)setupLeftView
{
    ZHLeftView *leftView = [ZHLeftView leftView];
    leftView.myFavsTV.delegate = leftView;
    leftView.myFavsTV.dataSource = leftView;
    leftView.x = -leftView.width;
    _leftView = leftView;
    [self.tabBarController.view addSubview:leftView];
    //点击add按钮回调的代码
    __weak typeof(self) weakSelf = self;
    __weak typeof(_leftView) weakLV = _leftView;
    [_leftView setAddClickBlock:^{
       //modal入addfac控制器
        ZHAddFavController *addFavVC = [[ZHAddFavController alloc]init];
        ZHNGViewController *nv = [[ZHNGViewController alloc]initWithRootViewController:addFavVC];
        
        
        //让关注tv刷新表格的block
        [addFavVC setRefreshBlock:^{
            weakLV.favsArray = [ZHMyFavs myFavs];
        }];
        
        __weak typeof(addFavVC) weakFavVC = addFavVC;
        [weakSelf presentViewController:nv animated:YES completion:^{
//         加载完控制器后加载球队数据
            [ZHHttpTool Get:ZHTeamsHotTeam parameters:nil acceptableContentTypes:@"text/html" success:^(id responseObject) {
                weakFavVC.dataSource = [ZHFavourite mj_objectArrayWithKeyValuesArray:responseObject];
            } failure:^(NSError *error) {
                NSLog(@"%@",error);
            }];
        }];
    }];
    //初始化时给左边栏的tableview传递数据
    _leftView.favsArray = [ZHMyFavs myFavs];
    
    
    //设置点击左边栏cell之后需要回调的代码
    [_leftView setCellClickHandler:^(ZHFavourite *fav) {
       //相当于点击了蒙版
        [weakSelf clickHUD];
       //重新设置被选中的team 并进行数据的刷新
        weakSelf.selectedTeam = fav;
        //进行球队锦标数据的请求
        
        [weakSelf requestTeamTrophies];
        //将球队保存到单例中
        [ZHMyFavs setSelTeam:weakSelf.selectedTeam];
        
        [weakSelf reloadData];
#warning pageView以及topView数据的刷新
//        weakSelf.
    }];
    
}

//请求球队锦标数的方法
- (void)requestTeamTrophies
{
    __weak typeof(self)weakSelf = self;
    //请求球队相对应的联赛锦标数量,并保存在模型zhfavourite的模型锦标中 
    [ZHHttpTool Get:ZHTeamsSeasonLeagueTrophiesResult(self.selectedTeam.team_id) parameters:nil acceptableContentTypes:@"text/html" success:^(id responseObject) {
        weakSelf.selectedTeam.trophies = [ZHTrophy mj_objectArrayWithKeyValuesArray:responseObject];
        [self reloadData];
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}
//左边栏滑动的方法
- (void)leftViewMove
{
    //判断此时leftView的位置
    if (_leftView.x == -_leftView.width) {
        if ((self.showLeftView = !self.isShowLeftView)) {
            return;
        }
        [UIView animateWithDuration:0.5 animations:^{
            _leftView.x = 0;//右滑!!!
        }];
        //添加一个蒙版用于屏蔽操作
        UIView *bgHUD = [[UIView alloc]initWithFrame:self.tabBarController.view.bounds];
        _HUDView = bgHUD;
        [self.tabBarController.view addSubview:bgHUD];
        //将leftView拿到最上面
        [self.tabBarController.view bringSubviewToFront:_leftView];
        bgHUD.backgroundColor = [UIColor lightGrayColor];
        bgHUD.alpha = 0.2;
        
        //添加手势点击后立即移除并滑动侧边栏
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickHUD)];
        [bgHUD addGestureRecognizer:tap];
    }
    else{
        if ((self.showLeftView = !self.isShowLeftView)) {
            return;
        }
        [UIView animateWithDuration:0.5 animations:^{
            _leftView.x = -_leftView.width;//左滑!!!
        }];
    }
}

//点击蒙版后 移除并移动左边栏
- (void)clickHUD
{
    [_HUDView removeFromSuperview];
    self.showLeftView = !self.showLeftView;
    [self leftViewMove];
}
#pragma mark 相关的数据刷新方法
-(void)reloadData
{
    //刷新topview 中的数据
    [self reloadTopViewData];
    //刷新pageview中的数据
    [_pageViewVC reloadData];
}

- (void)reloadTopViewData
{
    _topView.selectedTeam = self.selectedTeam;
}

#pragma mark umeng 分享代理
-(void)didFinishGetUMSocialDataResponse:(UMSocialResponseEntity *)response
{
    NSLog(@"%@",response);
}
@end
