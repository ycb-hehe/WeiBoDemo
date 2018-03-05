//
//  SendMessageToWeiboViewController.m
//  WeiboSDKDemo
//
//  Created by Wade Cheng on 3/29/13.
//  Copyright (c) 2013 SINA iOS Team. All rights reserved.
//

#import "SendMessageToWeiboViewController.h"
#import "LinkToWeiboViewController.h"
#import "AppDelegate.h"
#import "WeiboSDK.h"

@interface WBDataTransferObject ()
//@property (nonatomic, readonly) WeiboSDK3rdApp *app;
- (NSString *)validate;
- (void)storeToDictionary:(NSMutableDictionary *)dict;
- (void)loadFromDictionary:(NSDictionary *)dict;
+ (id)mappedObjectWithDictionary:(NSDictionary *)dict;
#ifdef WeiboSDKDebug
- (void)debugPrint;
#endif
@end

@interface SendMessageToWeiboViewController()<UIScrollViewDelegate,WBMediaTransferProtocol>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UISwitch *textSwitch;
@property (nonatomic, strong) UISwitch *imageSwitch;
@property (nonatomic, strong) UISwitch *mediaSwitch;
@property (nonatomic, strong) UISwitch *videoSwitch;
@property (nonatomic, strong) UISwitch *storySwitch;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) WBMessageObject *messageObject;

@end

@implementation SendMessageToWeiboViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.showsHorizontalScrollIndicator = YES;
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.numberOfLines = 3;
    [scrollView addSubview:self.titleLabel];
    self.titleLabel.text = NSLocalizedString(@"微博SDK示例", nil);
    
    UILabel *loginTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 70, 290, 20)];
    loginTextLabel.text = NSLocalizedString(@"登录:", nil);
    loginTextLabel.backgroundColor = [UIColor clearColor];
    loginTextLabel.textAlignment = NSTextAlignmentLeft;
    [scrollView addSubview:loginTextLabel];
    
    UIButton *ssoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [ssoButton setTitle:NSLocalizedString(@"请求微博认证（SSO授权）", nil) forState:UIControlStateNormal];
    [ssoButton addTarget:self action:@selector(ssoButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    ssoButton.frame = CGRectMake(20, 90, 280, 40);
    [scrollView addSubview:ssoButton];
    
    UIButton *ssoOutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [ssoOutButton setTitle:NSLocalizedString(@"登出", nil) forState:UIControlStateNormal];
    [ssoOutButton addTarget:self action:@selector(ssoOutButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    ssoOutButton.frame = CGRectMake(20, 130, 280, 40);
    [scrollView addSubview:ssoOutButton];
    
    UILabel *shareTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 170, 290, 20)];
    shareTextLabel.text = NSLocalizedString(@"分享:", nil);
    shareTextLabel.backgroundColor = [UIColor clearColor];
    shareTextLabel.textAlignment = NSTextAlignmentLeft;
    [scrollView addSubview:shareTextLabel];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 200, 80, 30)];
    textLabel.text = NSLocalizedString(@"文字", nil);
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textAlignment = NSTextAlignmentCenter;
    self.textSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(100, 200, 120, 30)];
    [scrollView addSubview:textLabel];
    [scrollView addSubview:self.textSwitch];
    
    UILabel *imageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 240, 80, 30)];
    imageLabel.text = NSLocalizedString(@"图片", nil);
    imageLabel.backgroundColor = [UIColor clearColor];
    imageLabel.textAlignment = NSTextAlignmentCenter;
    self.imageSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(100, 240, 120, 30)];
    [scrollView addSubview:imageLabel];
    [scrollView addSubview:self.imageSwitch];
    
    UILabel *mediaLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 280, 80, 30)];
    mediaLabel.text = NSLocalizedString(@"多媒体", nil);
    mediaLabel.backgroundColor = [UIColor clearColor];
    mediaLabel.textAlignment = NSTextAlignmentCenter;
    self.mediaSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(100, 280, 120, 30)];
    [scrollView addSubview:mediaLabel];
    [scrollView addSubview:self.mediaSwitch];
    
    UILabel *videoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 320, 80, 30)];
    videoLabel.text = NSLocalizedString(@"视频", nil);
    videoLabel.backgroundColor = [UIColor clearColor];
    videoLabel.textAlignment = NSTextAlignmentCenter;
    self.videoSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(100, 320, 120, 30)];
    [scrollView addSubview:videoLabel];
    [scrollView addSubview:self.videoSwitch];
    
    UILabel *storyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 360, 80, 30)];
    storyLabel.text = NSLocalizedString(@"story开关", nil);
    storyLabel.backgroundColor = [UIColor clearColor];
    storyLabel.textAlignment = NSTextAlignmentCenter;
    self.storySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(100, 360, 120, 30)];
    [scrollView addSubview:storyLabel];
    [scrollView addSubview:self.storySwitch];
    
    self.shareButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.shareButton.titleLabel.numberOfLines = 2;
    self.shareButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.shareButton setTitle:NSLocalizedString(@"分享消息到微博", nil) forState:UIControlStateNormal];
    [self.shareButton addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.shareButton.frame = CGRectMake(210, 200, 90, 110);
    [scrollView addSubview:self.shareButton];
    
    UILabel *linkWeiboLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 400, 290, 20)];
    linkWeiboLabel.text = NSLocalizedString(@"链接到微博API:", nil);
    linkWeiboLabel.backgroundColor = [UIColor clearColor];
    linkWeiboLabel.textAlignment = NSTextAlignmentLeft;
    [scrollView addSubview:linkWeiboLabel];
    
    UIButton *linkWeiboButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [linkWeiboButton setTitle:NSLocalizedString(@"链接到微博API Demo", nil) forState:UIControlStateNormal];
    [linkWeiboButton addTarget:self action:@selector(linkToWeiboAPI) forControlEvents:UIControlEventTouchUpInside];
    linkWeiboButton.frame = CGRectMake(20, 430, 280, 40);
    [scrollView addSubview:linkWeiboButton];
    
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, 530)];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    [super viewWillDisappear:animated];
}

-(void)messageShare
{
    AppDelegate *myDelegate =(AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = kRedirectURI;
    authRequest.scope = @"all";
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:_messageObject authInfo:authRequest access_token:myDelegate.wbtoken];
    request.userInfo = @{@"ShareMessageFrom": @"SendMessageToWeiboViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    if (![WeiboSDK sendRequest:request]) {
        [_indicatorView stopAnimating];
    }
}

- (void)shareButtonPressed
{
    _messageObject = [self messageToShare];
    
    if ((self.textSwitch.on || self.mediaSwitch.on) && (!self.imageSwitch.on && !self.videoSwitch.on) && self.storySwitch.on) {
        //只有文字和多媒体的时候打开分享到story开关，只会呼起发布器，没有意义
        return;
    }
    
    if (!self.imageSwitch.on && !self.videoSwitch.on) {
        [self messageShare];
    }else
    {
        if (!_indicatorView) {
            _indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            _indicatorView.center = self.view.center;
            [self.view addSubview:_indicatorView];
            _indicatorView.color = [UIColor blueColor];
        }
        
        [_indicatorView startAnimating];
        [_indicatorView setHidesWhenStopped:YES];
    }
}

- (void)ssoButtonPressed
{
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = kRedirectURI;
    request.scope = @"all";
    request.userInfo = @{@"SSO_From": @"SendMessageToWeiboViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    [WeiboSDK sendRequest:request];
}

- (void)ssoOutButtonPressed
{
    AppDelegate *myDelegate =(AppDelegate*)[[UIApplication sharedApplication] delegate];
    [WeiboSDK logOutWithToken:myDelegate.wbtoken delegate:self withTag:@"user1"];
}


- (void)linkToWeiboAPI
{
    LinkToWeiboViewController* linkToWeiboVC = [[LinkToWeiboViewController alloc] init];
    
    [self.navigationController pushViewController:linkToWeiboVC animated:YES];
}


- (void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result
{
    NSString *title = nil;
    UIAlertView *alert = nil;
    
    title = NSLocalizedString(@"收到网络回调", nil);
    alert = [[UIAlertView alloc] initWithTitle:title
                                       message:[NSString stringWithFormat:@"%@",result]
                                      delegate:nil
                             cancelButtonTitle:NSLocalizedString(@"确定", nil)
                             otherButtonTitles:nil];
    [alert show];
}

- (void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error;
{
    NSString *title = nil;
    UIAlertView *alert = nil;
    
    title = NSLocalizedString(@"请求异常", nil);
    alert = [[UIAlertView alloc] initWithTitle:title
                                       message:[NSString stringWithFormat:@"%@",error]
                                      delegate:nil
                             cancelButtonTitle:NSLocalizedString(@"确定", nil)
                             otherButtonTitles:nil];
    [alert show];
}

-(void)wbsdk_TransferDidReceiveObject:(id)object
{
    [_indicatorView stopAnimating];
    [self messageShare];
}

-(void)wbsdk_TransferDidFailWithErrorCode:(WBSDKMediaTransferErrorCode)errorCode andError:(NSError*)error
{
    [_indicatorView stopAnimating];
}

#pragma mark -
#pragma Internal Method

- (WBMessageObject *)messageToShare
{
    WBMessageObject *message = [WBMessageObject message];
    
    if (self.textSwitch.on)
    {
        message.text = NSLocalizedString(@"测试通过WeiboSDK发送文字到微博!", nil);
    }
    
    if (self.imageSwitch.on)
    {
        //        WBImageObject *image = [WBImageObject object];
        //        image.imageData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image_1" ofType:@"jpg"]];
        //        message.imageObject = image;
        
        UIImage *image = [UIImage imageNamed:@"WeiboSDK.bundle/images/empty_failed.png"];
        UIImage *image1 = [UIImage imageNamed:@"WeiboSDK.bundle/images/common_button_white.png"];
        UIImage *image2 = [UIImage imageNamed:@"WeiboSDK.bundle/images/common_button_white_highlighted.png"];
        NSArray *imageArray = [NSArray arrayWithObjects:image,image1,image2, nil];
        WBImageObject *imageObject = [WBImageObject object];
        if (self.storySwitch.on) {
            imageObject.isShareToStory = YES;
            imageArray = [NSArray arrayWithObject:image];
        }
        imageObject.delegate = self;
        [imageObject addImages:imageArray];
        message.imageObject = imageObject;
    }
    
    if (self.mediaSwitch.on)
    {
        WBWebpageObject *webpage = [WBWebpageObject object];
        webpage.objectID = @"identifier1";
        webpage.title = NSLocalizedString(@"分享网页标题", nil);
        webpage.description = [NSString stringWithFormat:NSLocalizedString(@"分享网页内容简介-%.0f", nil), [[NSDate date] timeIntervalSince1970]];
        webpage.thumbnailData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image_2" ofType:@"jpg"]];
        webpage.webpageUrl = @"http://weibo.com/p/1001603849727862021333?rightmod=1&wvr=6&mod=noticeboard";
        message.mediaObject = webpage;
    }
    
    if (self.videoSwitch.on) {
        WBNewVideoObject *videoObject = [WBNewVideoObject object];
        if (self.storySwitch.on) {
            videoObject.isShareToStory = YES;
        }
        NSURL *videoUrl = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"apm" ofType:@"mov"]];
        videoObject.delegate = self;
        [videoObject addVideo:videoUrl];
        message.videoObject = videoObject;
    }
    
    return message;
}


@end
