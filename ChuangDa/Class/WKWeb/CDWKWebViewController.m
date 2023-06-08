//
//  CDWKWebViewController.m
//  ChuangDa
//
//  Created by 宋直兵 on 2022/10/11.
//

#import "CDWKWebViewController.h"
#import "CDHomeWebHistoryModel.h"
#import <SSHelpTools/SSHelpWebView.h>

@interface CDWKWebViewController ()

@property(nonatomic, strong) UIProgressView *loadingPogressView;
@property(nonatomic, strong) SSHelpWebView *webView;

@end

@implementation CDWKWebViewController

- (void)dealloc
{
    [self.webView removeObserver:self forKeyPath:@"title"];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.webView];
    [self.view addSubview:self.loadingPogressView];
    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(goBack)];
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(goRefresh)];
    
    //加载进度
    [self.webView addObserver:self
                   forKeyPath:@"estimatedProgress"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
    
    //网页标题变化
    [self.webView addObserver:self
                   forKeyPath:@"title"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
    
    
    NSDictionary *dict = [[NSBundle mainBundle] infoDictionary];
    NSString *jsonString =SSEncodeStringFromDict(dict, @"LinkData");
    CDHomeWebHistoryModel *model = [CDHomeWebHistoryModel modelWithJsonString:jsonString];
    self.URL = model.URL;
    
    if (model.URL) {
        NSString *url = [model.URL stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
        NSMutableURLRequest *request  = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        [self.webView loadRequest:request];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewLayoutMarginsDidChange NS_REQUIRES_SUPER API_AVAILABLE(ios(11.0), tvos(11.0))
{
    [super viewLayoutMarginsDidChange];
    [self adjustSubViewFrame];
}

- (void)viewSafeAreaInsetsDidChange NS_REQUIRES_SUPER API_AVAILABLE(ios(11.0), tvos(11.0))
{
    [super viewSafeAreaInsetsDidChange];
    [self adjustSubViewFrame];
}

#pragma mark -
#pragma mark - Private Method

- (void)adjustSubViewFrame
{
    [self.webView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view.safeAreaInsets);
    }];
    [self.loadingPogressView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.webView);
        make.height.mas_equalTo(3);
    }];
}

- (void)goBack
{
    if ([self.webView canGoBack]) {
        [self.webView.backForwardList.backList enumerateObjectsUsingBlock:^(WKBackForwardListItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            SSLog(@"第%ld页：%@",idx,obj.URL);
        }];
        [self.webView goBack];
    } else {
        if (self.navigationController && self.navigationController.viewControllers.count > 1) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (void)goRefresh
{
    [self.webView reload];
}


#pragma mark -
#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {   //加载进度值
        self.loadingPogressView.alpha = 1;
        [self.loadingPogressView setProgress:self.webView.estimatedProgress animated:YES];
        if (self.webView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.5f
                                  delay:0.3f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 [self.loadingPogressView setAlpha:0.0f];
                             }
                             completion:^(BOOL finished) {
                                 [self.loadingPogressView setProgress:0.0f animated:NO];
                             }];
        }
    } else if ([keyPath isEqualToString:@"title"]) { //网页title
        if (self.webView) {
            self.title = self.webView.title;
            //SSLog(@"网页新标题:%@",self.webView.title);
        }
    }
}

#pragma mark -
#pragma mark - Getter

- (SSHelpWebView *)webView
{
    if (!_webView) {
        _webView = [SSHelpWebView defauleWebView];
    }
    return _webView;
}

- (UIProgressView *)loadingPogressView
{
    if (!_loadingPogressView) {
        _loadingPogressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _loadingPogressView.progressTintColor = [[UIColor blueColor] colorWithAlphaComponent:0.85];
        _loadingPogressView.trackTintColor = [UIColor clearColor];
    }
    return _loadingPogressView;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
