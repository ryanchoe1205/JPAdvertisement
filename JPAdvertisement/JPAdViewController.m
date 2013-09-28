//
//  JPAdViewController.m
//  JPAdvertisement
//
//  Created by Leonardo Redmond on 9/27/13.
//  Copyright (c) 2013 IdiogenicOsmoles & PasquaLabs. All rights reserved.
//

#import "JPAdViewController.h"



@interface JPAdViewController ()
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
@end

@implementation JPAdViewController

@synthesize adWebViewSize;
@synthesize currentContentSizeIdentifier;
@synthesize adWebViewCloseButton;


+ (CGRect) adWebViewRectForCurrentInterface:(NSString *)contentSizeIdentifier adWebViewSize:(CGSize) adWebViewSize
{
    CGFloat left = 0;
    CGFloat top = 0;
    
    CGSize deviceSize;
    
    if (contentSizeIdentifier == JPAdvertisementHandheldLandscape) {
		deviceSize = handheldLandscapeSize;
	} else if (contentSizeIdentifier == JPAdvertisementHandheldPortrait) {
		deviceSize = handheldPortraitSize;
	} else if (contentSizeIdentifier == JPAdvertisementTabletLandscape) {
		deviceSize = tabletLandscapeSize;
	} else if (contentSizeIdentifier == JPAdvertisementTabletPortrait) {
		deviceSize = tabletPortraitSize;
	} else
		deviceSize = CGSizeZero;
    
    left = (deviceSize.width - adWebViewSize.width) / 2;
    top = (deviceSize.height - adWebViewSize.height) / 2;
//    return (CGPoint){left, top};
    return (CGRect){left, top, adWebViewSize.width, adWebViewSize.height};
}

- (CGRect) adWebViewRectForCurrentInterface:(NSString *)contentSizeIdentifier adWebViewSize:(CGSize) adWebViewSize {
    return [JPAdViewController adWebViewRectForCurrentInterface:contentSizeIdentifier adWebViewSize:self.adWebViewSize];
}

+ (CGRect) adWebViewCloseButtonRectForCurrentInterface:(NSString *)contentSizeIdentifier adWebViewSize:(CGSize) adWebViewSize {
    CGFloat left = 0;
    CGFloat top = 0;
    
    CGSize deviceSize;
    
    if (contentSizeIdentifier == JPAdvertisementHandheldLandscape) {
		deviceSize = handheldLandscapeSize;
	} else if (contentSizeIdentifier == JPAdvertisementHandheldPortrait) {
		deviceSize = handheldPortraitSize;
	} else if (contentSizeIdentifier == JPAdvertisementTabletLandscape) {
		deviceSize = tabletLandscapeSize;
	} else if (contentSizeIdentifier == JPAdvertisementTabletPortrait) {
		deviceSize = tabletPortraitSize;
	} else
		deviceSize = CGSizeZero;
    
    left = (deviceSize.width - adWebViewSize.width) / 2 +100;
    top = (deviceSize.height - adWebViewSize.height) / 2;
    return (CGRect){adWebViewSize.width -20, 0, 20, 20};
    
}

- (CGRect) adWebViewCloseButtonRectForCurrentInterface:(NSString *)contentSizeIdentifier adWebViewSize:(CGSize) adWebViewSize {
    return [JPAdViewController adWebViewCloseButtonRectForCurrentInterface:contentSizeIdentifier adWebViewSize:self.adWebViewSize];
}

- (id) initWith:(CGSize)viewSize adWebViewURL:(NSString*)adWebViewURL{
    self = [super init];
    if (self) {
        self.adWebViewSize = viewSize;
        currentContentSizeIdentifier = contentSizeIdentifierForCurrentInterface();
        UIWebView *webView=[[UIWebView alloc]initWithFrame:[self adWebViewRectForCurrentInterface:currentContentSizeIdentifier adWebViewSize:viewSize]];
        webView.delegate = self;
        self.view = webView;
        NSString *url = adWebViewURL;
        NSURL *nsurl = [NSURL URLWithString:url];
        NSURLRequest *nsrequest = [NSURLRequest requestWithURL:nsurl];
        [webView loadRequest:nsrequest];
        webView.scrollView.bounces = NO;
        self.view = webView;
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.adWebViewCloseButton = closeButton;
        [self.adWebViewCloseButton  setTitle:@"X" forState:UIControlStateNormal];
        self.adWebViewCloseButton.frame = [self adWebViewCloseButtonRectForCurrentInterface:currentContentSizeIdentifier adWebViewSize:self.adWebViewSize];
        [self.adWebViewCloseButton addTarget:self action:@selector(adWebViewCloseButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.adWebViewCloseButton];
    }
    return self;
}

-(void) adWebViewCloseButtonTapped:(UIButton *)sender{
    
     [self.delegate adView_BeforeClose];
     [self.view removeFromSuperview];
    [self.delegate adView_AfterClose];
  
}
- (void)viewDidLoad
{
    [super viewDidLoad];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSURL* absURL=[request.mainDocumentURL absoluteURL];
    NSString* sURL=[absURL absoluteString];
    
    if ([@"fakeURL://login" isEqualToString:sURL]) {
        return NO;
    }else if ([@"otherURL://getAddressBook" isEqualToString:sURL]){
        return NO;
    }else if ([sURL hasPrefix:@"https://"]){
        
        [[UIApplication sharedApplication] openURL:absURL];
        
        [self.delegate adView_Tapped:absURL];
        return NO;
    }
    return YES;
}



@end
