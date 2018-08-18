//
//  MMKitWebViewController.m
//  MMKit
//
//  Created by Dwang on 2018/5/5.
//  Copyright © 2018年 CoderDwang. All rights reserved.
//

#define SCREEN_BOUNDS [UIScreen mainScreen].bounds.size

#import "MMKitWebViewController.h"
#import "UIBarButtonItem+MMKit.h"
#import "UIViewController+MMKit.h"
#import "MBProgressHUD.h"
#import "Reachability.h"

static BOOL _hasExit = NO;
static BOOL _autoHiddenToolBar = NO;
static BOOL _hasSaveImage = NO;

@interface MMKitWebViewController ()<UIWebViewDelegate, UIGestureRecognizerDelegate>

@property(nonatomic, strong) UIToolbar *toolBar;

@property(nonatomic, strong) UIWebView *webView;

@property(nonatomic, strong) NSMutableURLRequest *request;

@property(nonatomic, copy) NSString *baseUrlString;

@property (nonatomic, strong) Reachability *reach;

@end

@implementation MMKitWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    self.reach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    [self.reach startNotifier];
}

- (void)extracted:(MMKitWebViewController *const __weak)weakSelf {
    [weakSelf mmkit_resetConfig];
}

- (void)reachabilityChanged:(NSNotification*)note {
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus status = [curReach currentReachabilityStatus];
    if (status == NotReachable) {
        __weak __typeof(self)weakSelf = self;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"您的设备当前似乎没有可用网络" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"重试" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (weakSelf.webView.canGoBack) {
                [weakSelf.webView reload];
            }else {
                [self mmkit_resetConfig];
            }
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (instancetype)initWithUrlString:(NSString *)urlString autoHiddenToolBar:(BOOL)autoHiddenToolBar saveImage:(BOOL)saveImage {
    self = [super init];
    if (self) {
        _autoHiddenToolBar = autoHiddenToolBar;
        _hasSaveImage = saveImage;
        [self mmkit_initWithWebUrlString:urlString];
    }
    return self;
}

- (instancetype)initWithExitUrlString:(NSString *)urlString autoHiddenToolBar:(BOOL)autoHiddenToolBar saveImage:(BOOL)saveImage {
    self = [super init];
    if (self) {
        _hasExit = YES;
        _hasSaveImage = saveImage;
        _autoHiddenToolBar = autoHiddenToolBar;
        [self mmkit_initWithWebUrlString:urlString];
    }
    return self;
}

- (void)mmkit_initWithWebUrlString:(NSString *)urlString {
    if ([urlString hasPrefix:@"http://"] || [urlString hasPrefix:@"https://"]) {
        self.baseUrlString = urlString;
    }else {
        self.baseUrlString = [NSString stringWithFormat:@"http://%@", urlString];
    }
    [self.view addSubview:self.toolBar];
    [self.view addSubview:self.webView];
    [self mmkit_resetConfig];
}

- (void)mmkit_homeDidClick {
    [self mmkit_resetConfig];
}

- (void)mmkit_backDidClick {
    [self.webView goBack];
    [self mmkit_updateToolBar];
}

- (void)mmkit_forwardDidClick {
    [self.webView goForward];
    [self mmkit_updateToolBar];
}

- (void)mmkit_reloadDidClick {
    [self.webView reload];
}

- (void)mmkit_cancelDidClick {
    [self.webView stopLoading];
    [self mmkit_defaultToolBar];
}

- (void)mmkit_exitDidClick {
    exit(0);
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [MBProgressHUD showHUDAddedTo:self.webView animated:YES];
    [self mmkit_cancelToolBar];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self mmkit_defaultToolBar];
    [self mmkit_updateToolBar];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.webView animated:YES];
    [self mmkit_defaultToolBar];
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    if ([challenge previousFailureCount] == 0) {
        NSURLCredential* cre = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        [challenge.sender useCredential:cre forAuthenticationChallenge:challenge];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [self.webView loadRequest:_request];
    [connection cancel];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (_autoHiddenToolBar) {
        if (orientation == UIInterfaceOrientationLandscapeLeft ||
            orientation == UIInterfaceOrientationLandscapeRight) {
            self.webView.frame = CGRectMake(0, 0, size.width, size.height-44);
            self.toolBar.frame = CGRectMake(0, size.height-44, size.width, 44);
            self.toolBar.hidden = NO;
        }else {
            self.webView.frame = CGRectMake(0, 0, size.width, size.height);
            self.toolBar.hidden = YES;
        }
    }else {
        self.webView.frame = CGRectMake(0, 0, size.width, size.height-44);
        self.toolBar.frame = CGRectMake(0, size.height-44, size.width, 44);
    }
}

- (void)mmkit_resetConfig {
    if ([self.baseUrlString hasPrefix:@"https://"]) {
        _request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.baseUrlString]];
        [NSURLConnection connectionWithRequest:_request delegate:self];
    }else {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.baseUrlString] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.f]];
    }
    self.toolBar.items[0].enabled = NO;
    self.toolBar.items[2].enabled = NO;
    self.toolBar.items[4].enabled = NO;
}

- (void)mmkit_updateToolBar {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [MBProgressHUD hideHUDForView:self.webView animated:YES];
    self.toolBar.items[0].enabled = self.webView.canGoBack;
    self.toolBar.items[2].enabled = self.webView.canGoBack;
    self.toolBar.items[4].enabled = self.webView.canGoForward;
}

- (void)mmkit_cancelToolBar {
    NSMutableArray <UIBarButtonItem *>*toolItems = [NSMutableArray arrayWithArray:self.toolBar.items];
    [toolItems replaceObjectAtIndex:6 withObject:[self mmkit_itemWithCancelAction:@selector(mmkit_cancelDidClick)]];
    self.toolBar.items = toolItems;
}

- (void)mmkit_defaultToolBar {
    NSMutableArray <UIBarButtonItem *>*toolItems = [NSMutableArray arrayWithArray:self.toolBar.items];
    [toolItems replaceObjectAtIndex:6 withObject:[self mmkit_itemWithImageName:@"刷新" action:@selector(mmkit_reloadDidClick)]];
    self.toolBar.items = toolItems;
}

- (UIToolbar *)toolBar {
    if (!_toolBar) {
        _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, SCREEN_BOUNDS.height-44, SCREEN_BOUNDS.width, 44)];
        NSMutableArray <UIBarButtonItem *>*items = [NSMutableArray array];
        [items addObject:[self mmkit_itemWithImageName:@"首页" action:@selector(mmkit_homeDidClick)]];
        [items addObject:[UIBarButtonItem mmkit_flexibleSpace]];
        [items addObject:[self mmkit_itemWithImageName:@"返回" action:@selector(mmkit_backDidClick)]];
        [items addObject:[UIBarButtonItem mmkit_flexibleSpace]];
        [items addObject:[self mmkit_itemWithImageName:@"前进" action:@selector(mmkit_forwardDidClick)]];
        [items addObject:[UIBarButtonItem mmkit_flexibleSpace]];
        [items addObject:[self mmkit_itemWithImageName:@"刷新" action:@selector(mmkit_reloadDidClick)]];
        if (_hasExit) {
            [items addObject:[UIBarButtonItem mmkit_flexibleSpace]];
            [items addObject:[self mmkit_itemWithImageName:@"退出" action:@selector(mmkit_exitDidClick)]];
        }
        _toolBar.items = items;
    }
    return _toolBar;
}

- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_BOUNDS.width, SCREEN_BOUNDS.height-44)];
        _webView.delegate = self;
        _webView.scalesPageToFit = YES;
        _webView.backgroundColor = [UIColor whiteColor];
        if (_hasSaveImage) {
            UILongPressGestureRecognizer *longPressed = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(mmkit_longPressed:)];
            longPressed.delegate = self;
            longPressed.minimumPressDuration = .5f;
            [_webView addGestureRecognizer:longPressed];
        }
    }
    return _webView;
}

- (void)mmkit_longPressed:(UIGestureRecognizer*)ges {
    CGPoint point = [ges locationInView:self.webView];
    NSString *jsStr = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src",point.x,point.y];
    NSString *imageUrlStr = [self.webView stringByEvaluatingJavaScriptFromString:jsStr];
    if ([imageUrlStr length]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        __weak __typeof(self)weakSelf = self;
        [alert addAction:[UIAlertAction actionWithTitle:@"保存图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [MBProgressHUD showHUDAddedTo:weakSelf.webView animated:YES];
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrlStr]]];
            if (image) {
                UIImageWriteToSavedPhotosAlbum(image, weakSelf, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
            }else {
                
            }
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [MBProgressHUD hideHUDForView:self.webView animated:YES];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    if (error) {
        alert.title = @"图片保存失败，无法访问相册";
        alert.message = @"请在“设置>隐私>照片”打开相册访问权限";
    }else{
        alert.message = @"图片保存成功";
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

@end


