//
//  CDHomeViewController.m
//  ChuangDa
//
//  Created by 宋直兵 on 2022/10/10.
//

#import "CDHomeViewController.h"
#import "CDQRCodeVC.h"
#import "CDHomeCollectionViewCell.h"
#import "CDWKWebViewController.h"
#import "CDStorageManager.h"
#import "CDSettingViewController.h"

#import <UICKeyChainStore/UICKeyChainStore.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <IFMMenu/IFMMenu.h>
#import <YCXMenu/YCXMenu.h>

@interface CDHomeViewController()
<UICollectionViewDelegate,
UICollectionViewDataSource,SSHelpCollectionViewLayoutDataSource,CDQRCodeDelegate>

@property(nonatomic, strong) NSMutableArray <CDHomeWebHistoryModel *> *historyURL;
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) SSHelpButton *scanBtn;

@end

@implementation CDHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupNavigationBar];
    [self.view addSubview:self.collectionView];
    //[self.view addSubview:self.scanBtn];
    [self addGestureRecognizer];
    
    @Tweakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSDictionary *dict = [[NSBundle mainBundle] infoDictionary];
        
        NSString *jsonString =SSEncodeStringFromDict(dict, @"LinkData");// @"{\"code\":\"chuangDa\", \"name\": \"云网\", \"url\": \"https://www.gccloud.com\"}";
        //002 数据处理
        CDHomeWebHistoryModel *newModel = [CDHomeWebHistoryModel modelWithJsonString:jsonString];
        if (newModel) {
            __block CDHomeWebHistoryModel *sameModel = nil;
            __block NSInteger index = 0;
            [self_weak_.historyURL enumerateObjectsUsingBlock:^(CDHomeWebHistoryModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.code isEqual:newModel.code]) {
                    sameModel = obj;
                    index = idx;
                    *stop = YES;
                }
            }];
            
            if (sameModel) {
                if ([sameModel.jsonString isEqualToString:newModel.jsonString]) {
                    //完全一样, 不做处理
                    SSLog(@"数据相同...");
                } else {
                    //不一样, 更新
                    BOOL updateStatus = [[CDStorageManager sharedManager] updateHomeWebHistoryModel:newModel];
                    if (updateStatus) {
                        SSLog(@"数据更新成功...");
                    } else {
                        SSLog(@"数据更新失败...");
                    }
                    //刷新首页
                    [self_weak_.historyURL replaceObjectAtIndex:index withObject:newModel];
                    [self_weak_.collectionView reloadData];
                }
            } else {
                BOOL insetStatus = [[CDStorageManager sharedManager] saveHomeWebHistoryModel:newModel];
                if (insetStatus) {
                    SSLog(@"数据插入成功...");
                } else {
                    SSLog(@"数据插入失败...");
                }
                //刷新首页
                [self_weak_.historyURL addObject:newModel];
                [self_weak_.collectionView reloadData];
            }
        }
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    NSString *firstOpen = [UICKeyChainStore stringForKey:@"firstOpentime"];
//    if (self.historyURL.count<=0 && firstOpen.length==0) {
//        [UICKeyChainStore setString:[NSDate ss_currentTime] forKey:@"firstOpentime"];
//        [self goToScanViewController];
//    } else {
//        SSLog(@"The first open time is : %@",firstOpen);
//    }
}

- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view.safeAreaInsets);
    }];
}


#pragma mark -
#pragma mark - Private Method

- (void)setupNavigationBar
{
    @Tweakify(self);
    self.navigationItem.title = @"应用列表";
    
    SSHelpButton *moreBtn = [SSHelpButton buttonWithStyle:SSButtonStyleCustom];
    moreBtn.normalImage = [UIImage imageNamed:@"cd_add_64x64"];
    moreBtn.imageRect = CGRectMake(64-30, 6, 30, 30);
    moreBtn.onClick = ^(SSHelpButton * _Nonnull sender) {
        [self_weak_ goToScanViewController];
    };
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
}

- (void)goToScanViewController
{
    CDQRCodeVC *qrcode = [[CDQRCodeVC alloc] init];
    qrcode.delegate = self;
    [self.navigationController pushViewController:qrcode animated:YES];
    
    @Tweakify(self);
    [[[[self rac_signalForSelector:@selector(scanCodeVC:result:) fromProtocol:@protocol(CDQRCodeDelegate)] deliverOnMainThread] takeUntil:qrcode.rac_willDeallocSignal]subscribeNext:^(RACTuple * _Nullable x) {
        
        CDQRCodeVC *vc = x.first;
        NSString *jsonString = x.last;
        
        //001 页面返回
        vc.delegate = nil;
        [vc.navigationController popViewControllerAnimated:NO];
        
        //002 数据处理
        CDHomeWebHistoryModel *newModel = [CDHomeWebHistoryModel modelWithJsonString:jsonString];
        if (newModel) {
            __block CDHomeWebHistoryModel *sameModel = nil;
            __block NSInteger index = 0;
            [self_weak_.historyURL enumerateObjectsUsingBlock:^(CDHomeWebHistoryModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.code isEqual:newModel.code]) {
                    sameModel = obj;
                    index = idx;
                    *stop = YES;
                }
            }];
            
            if (sameModel) {
                if ([sameModel.jsonString isEqualToString:newModel.jsonString]) {
                    //完全一样, 不做处理
                    SSLog(@"数据相同...");
                } else {
                    //不一样, 更新
                    BOOL updateStatus = [[CDStorageManager sharedManager] updateHomeWebHistoryModel:newModel];
                    if (updateStatus) {
                        SSLog(@"数据更新成功...");
                    } else {
                        SSLog(@"数据更新失败...");
                    }
                    //刷新首页
                    [self_weak_.historyURL replaceObjectAtIndex:index withObject:newModel];
                    [self_weak_.collectionView reloadData];
                }
            } else {
                BOOL insetStatus = [[CDStorageManager sharedManager] saveHomeWebHistoryModel:newModel];
                if (insetStatus) {
                    SSLog(@"数据插入成功...");
                } else {
                    SSLog(@"数据插入失败...");
                }
                //刷新首页
                [self_weak_.historyURL addObject:newModel];
                [self_weak_.collectionView reloadData];
            }
            
            //跳转页面
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self_weak_ goToWebViewController:newModel];
            });
        }
    }];
}

- (void)goToWebViewController:(CDHomeWebHistoryModel *)model
{
    CDWKWebViewController *webVC = [[CDWKWebViewController alloc] init];
    webVC.URL = model.URL;
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)goToSettingViewController
{
    CDSettingViewController *settingVC = [[CDSettingViewController alloc] init];
    [self.navigationController pushViewController:settingVC animated:YES];
}

- (void)addGestureRecognizer
{
    @Tweakify(self);
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] init];
    [self.collectionView addGestureRecognizer:gesture];
    [[[[gesture rac_gestureSignal] takeUntil:self.collectionView.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
        if (x && (x.state == UIGestureRecognizerStateBegan)) {
            CGPoint pint = [x locationInView:self_weak_.collectionView];
            NSIndexPath *indexPath = [self_weak_.collectionView indexPathForItemAtPoint:pint];
            if (indexPath && (indexPath.item>=0 || indexPath.item<self_weak_.historyURL.count)) {
                CDHomeWebHistoryModel *model = self_weak_.historyURL[indexPath.item];
                [[CDStorageManager sharedManager] removeHomeWebHistoryModels:@[model]];

                [self_weak_.historyURL removeObjectAtIndex:indexPath.item];
                [self_weak_.collectionView reloadData];
            }
        }
    }];
}

#pragma mark -
#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self goToWebViewController:self.historyURL[indexPath.item]];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.historyURL.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CDHomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CDHomeCollectionViewCell" forIndexPath:indexPath];
    [cell refreshWithModel:self.historyURL[indexPath.item]];
    return cell;
}

#pragma mark -
#pragma mark - SSHelpCollectionViewLayoutDataSource

/// Return per section's column number(must be greater than 0).
- (NSInteger)collectionView:(UICollectionView *)collectionView
                     layout:(SSHelpCollectionViewLayout*)layout
    numberOfColumnInSection:(NSInteger)section
{
    return 2;
}

/// Return per item's height
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(SSHelpCollectionViewLayout*)layout itemWidth:(CGFloat)width
 heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

/// Return per item's size，横向限制布局必须返回
- (CGSize)collectionView:(UICollectionView *)collectionView
                   layout:(SSHelpCollectionViewLayout*)layout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeZero;
}

//@optional


/// Column spacing between columns
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SSHelpCollectionViewLayout*)layout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 20;
}

/// The spacing between rows and rows
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SSHelpCollectionViewLayout*)layout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 20;
}
 
///
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(SSHelpCollectionViewLayout*)layout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(20, 20, 20, 20);
}

/*
/// Return per section header view height.
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SSHelpCollectionViewLayout*)layout referenceHeightForHeaderInSection:(NSInteger)section
{
    
}

/// Return per section footer view height.
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SSHelpCollectionViewLayout*)layout referenceHeightForFooterInSection:(NSInteger)section
{
    
}
*/
#pragma mark -
#pragma mark - Getter

- (UICollectionView *)collectionView
{
    if (!_collectionView){
        SSHelpCollectionViewLayout *layout = [[SSHelpCollectionViewLayout alloc] init];
        layout.dataSource = self;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = SSHELPTOOLSCONFIG.backgroundColor;
        [_collectionView registerClass:[CDHomeCollectionViewCell class] forCellWithReuseIdentifier:@"CDHomeCollectionViewCell"];
    }
    return _collectionView;
}

- (NSMutableArray<CDHomeWebHistoryModel *> *)historyURL
{
    if(!_historyURL){
        _historyURL = [[NSMutableArray alloc] init];
        [_historyURL addObjectsFromArray:[[CDStorageManager sharedManager] getAllHomeWebHistoryModels]];
    }
    return _historyURL;
}

- (SSHelpButton *)scanBtn
{
    if (!_scanBtn) {
        @Tweakify(self);
        CGSize buttonSize = CGSizeMake(80, 80);
        CGRect initialButtonFrame = CGRectMake((self.view.ss_width-buttonSize.width)/2.0,
                                               self.view.ss_height-buttonSize.height-20,
                                               buttonSize.width,
                                               buttonSize.height);
        
        _scanBtn = [SSHelpButton buttonWithType:UIButtonTypeRoundedRect];
        _scanBtn.normalImage = [UIImage imageNamed:@"cd_sance_icon_60x60"];
        _scanBtn.imageRect = CGRectMake(10, 10, 60, 60);
        _scanBtn.frame = initialButtonFrame;
        _scanBtn.layer.masksToBounds = YES;
        _scanBtn.layer.cornerRadius = 10;
        _scanBtn.backgroundColor = SSHELPTOOLSCONFIG.tertiaryFillColor;
        [[_scanBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            [self_weak_ goToScanViewController];
        }];
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
        [[panGestureRecognizer rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable recognizer) {
            CGPoint translation = [recognizer translationInView:self_weak_.view];
            CGFloat centerX = recognizer.view.center.x+ translation.x;
            CGFloat thecenter = 0;
            recognizer.view.center = CGPointMake(centerX,recognizer.view.center.y+ translation.y);
            [recognizer setTranslation:CGPointZero inView:self_weak_.view];
        
            if (recognizer.state==UIGestureRecognizerStateEnded|| recognizer.state==UIGestureRecognizerStateCancelled) {
                if (centerX>self_weak_.view.ss_width/2) {
                    thecenter = self_weak_.view.ss_width-80/2-2; //偏移2
                } else {
                    thecenter = 80/2+2; //偏移2
                }
                [UIView animateWithDuration:0.3 animations:^{
                    recognizer.view.center = CGPointMake(thecenter,recognizer.view.center.y+ translation.y);
                }];
            }
        }];
        //[_scanBtn addGestureRecognizer:panGestureRecognizer];
    }
    return _scanBtn;
}

@end
