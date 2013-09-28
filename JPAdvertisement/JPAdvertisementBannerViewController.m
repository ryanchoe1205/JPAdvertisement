//
//  JPAdvertisementBannerViewController.m
//  JPAdvertisement
//
//  Created by Joe on 4/26/11.
/*
 
 http://joepasq.com 
 https://github.com/joepasq
 http://joepasq.com/documentation/jpadvertisement
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software in binary form, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "JPAdvertisementBannerViewController.h"
#
CGSize handheldPortraitSizeForAdButton = {320, 50};
CGSize handheldLandscapeSizeForAdButton = {480, 32};

CGSize tabletPortraitSizeForAdButton = {768, 66};
CGSize tabletLandscapeSizeForAdButton = {1024, 66};

CGSize adWebViewNormalSize = {300, 250};
NSString* adButtonNormalText = @"Continue";

@interface JPAdvertisementBannerViewController ()

- (void) deviceRotated:(id) sender;

- (void)openReferralURL:(NSURL *)referralURL;
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

- (void) layoutAdForCurrentOrientation;

@end;


@implementation JPAdvertisementBannerViewController

@synthesize adButton;
@synthesize adWebView;
@synthesize adWebBackgroundView;

@synthesize adWebViewController;

@synthesize adURL, linkShareURL;
@synthesize affiliatedLink;

@synthesize adImagePortrait, adImageLandscape;

@synthesize adButtonType;
@synthesize adWebViewSize;
@synthesize adWebViewLoaded;
@synthesize adWebViewURL;
@synthesize adViewButtonText;

@synthesize requiredContentSizeIdentifiers, currentContentSizeIdentifier;

@synthesize adClicked, clickThroughFailed;

@synthesize hidden, frame;


#pragma mark - Ad Loading

- (BOOL) loadAdFromPlistNamed:(NSString *) plist {
	
	NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:plist ofType:@"plist"]];
	
	if (data != nil) {
		self.adURL = [NSURL URLWithString:[data valueForKey:@"adURL"]];
		self.affiliatedLink = [data valueForKey:@"affiliatedLink"] ? YES : NO;
		
		self.adImagePortrait = [data valueForKey:@"portraitImage"];
		self.adImageLandscape = [data valueForKey:@"landscapeImage"];
		
		NSString *fileAdURL = [data valueForKey:@"adURL"];
		
		if ([fileAdURL isEqualToString:@"nil"] || [fileAdURL isEqualToString:@""]) {
			[self.adButton removeTarget:self action:@selector(adTapped:) forControlEvents:UIControlEventTouchUpInside];
		}
		
		[self layoutAdForCurrentOrientation];
		return YES;
	} else
		return NO;
}

- (BOOL) loadAd {
	return [self loadAdFromPlistNamed:@"Grades_website"]; //Switch to Grades_appstore on device to see LinkShare URL in action.
}


#pragma mark - Advertisement handling

- (void) adTapped:(UIButton *) sender {
    if (adButtonType == JPAdvertisementAdImageButton){
        if (affiliatedLink) {
            [self openReferralURL:self.adURL];
        } else {
            if ([[UIApplication sharedApplication] canOpenURL:self.adURL]) {
                if (self.adClicked)
                    self.adClicked();
                [[UIApplication sharedApplication] openURL:self.adURL];
            } else
                if (self.clickThroughFailed)
                    self.clickThroughFailed();
        }
    } else {
        if (self.adView_WillAppear)
            self.adView_WillAppear();
        self.frame = [self adWebBackgroundViewRectForCurrentInterface:currentContentSizeIdentifier];
        UIView *backgroundView = [[UIView alloc] initWithFrame:[self adWebBackgroundViewRectForCurrentInterface:currentContentSizeIdentifier]];
        self.adWebBackgroundView = backgroundView;
        [self.adWebBackgroundView setBackgroundColor:[UIColor blackColor]];
        [self.adWebBackgroundView setOpaque:NO];
        [self.adWebBackgroundView setAlpha:0.7];
        [self.view addSubview:self.adWebBackgroundView];
        
        self.adWebViewController = [[JPAdViewController alloc] initWith:self.adWebViewSize adWebViewURL:adWebViewURL];
        self.adWebViewController.delegate = self;
        self.adWebView = self.adWebViewController.view;
        [self.view addSubview:self.adWebView];
        self.adWebViewLoaded = TRUE;
    }
}

-(void) adView_BeforeClose{
    if (self.adView_WillDisappear)
        self.adView_WillDisappear();
    [self.adWebBackgroundView removeFromSuperview];
}
-(void) adView_AfterClose{
    self.adWebViewLoaded = FALSE;
}

-(void)adView_Tapped:(NSURL*)adURL{
    if ([[UIApplication sharedApplication] canOpenURL:self.adURL]) {
        if (self.adClicked)
            self.adClicked();
        [[UIApplication sharedApplication] openURL:self.adURL];
    } else
        if (self.clickThroughFailed)
            self.clickThroughFailed();
}
#pragma mark - Ad Sizing

+ (CGSize) sizeFromBannerContentSizeIdentifier:(NSString *)contentSizeIdentifier {
	if (contentSizeIdentifier == JPAdvertisementHandheldLandscape) {
		return handheldLandscapeSizeForAdButton;
	} else if (contentSizeIdentifier == JPAdvertisementHandheldPortrait) {
		return handheldPortraitSizeForAdButton;
	} else if (contentSizeIdentifier == JPAdvertisementTabletLandscape) {
		return tabletLandscapeSizeForAdButton;
	} else if (contentSizeIdentifier == JPAdvertisementTabletPortrait) {
		return tabletPortraitSizeForAdButton;
	} else
		return CGSizeZero;
}

- (CGSize) sizeFromBannerContentSizeIdentifier:(NSString *)contentSizeIdentifier {
	return [JPAdvertisementBannerViewController sizeFromBannerContentSizeIdentifier:contentSizeIdentifier];
}

+ (CGPoint) adWebViewPointForCurrentInterface:(NSString *)contentSizeIdentifier adWebViewSize:(CGSize) adWebViewSize {
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
    return (CGPoint){left, top};
}
 - (CGPoint) adWebViewPointForCurrentInterface:(NSString *)contentSizeIdentifier adWebViewSize:(CGSize) adWebViewSize {
     return [JPAdvertisementBannerViewController adWebViewPointForCurrentInterface:contentSizeIdentifier adWebViewSize:self.adWebViewSize];
 }
+ (CGRect) adWebBackgroundViewRectForCurrentInterface:(NSString *)contentSizeIdentifier{
    
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
    
    return (CGRect){0, 0, deviceSize.width, deviceSize.height};
}

- (CGRect) adWebBackgroundViewRectForCurrentInterface:(NSString *)contentSizeIdentifier{
    return [JPAdvertisementBannerViewController adWebBackgroundViewRectForCurrentInterface:contentSizeIdentifier];
}
#pragma mark - LinkShare

// Process a LinkShare/TradeDoubler/DGM URL to something iPhone can handle
- (void)openReferralURL:(NSURL *)referralURL {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    if ([[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:adURL] delegate:self startImmediately:YES] == nil)
		NSLog(@"!! Error in NSURLConnection initialization. JPAdvertisementBannerViewController %d", __LINE__);
}

// Save the most recent URL in case multiple redirects occur
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    self.linkShareURL = [response URL];
    return request;
}

// No more redirects; use the last URL saved
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	UIApplication *app = [UIApplication sharedApplication];
	[app setNetworkActivityIndicatorVisible:NO];
	
	if ([app canOpenURL:self.linkShareURL]) {
		if (self.adClicked)
			self.adClicked();
		[app openURL:self.linkShareURL];
	} else {
		if (self.clickThroughFailed)
			self.clickThroughFailed();
	}
}

#pragma mark - Exposed UIView methods

- (void) setHidden:(BOOL)paramHidden {
	self.view.hidden = paramHidden;
}

- (BOOL) isHidden {
	return [self.view isHidden];
}

- (void) setFrame:(CGRect)paramFrame {
	self.view.frame = paramFrame;
}

- (CGRect) frame {
	return self.view.frame;
}

#pragma mark - Initializers

- (id) init {
	return [self initWithOrigin:CGPointZero];
}

- (id) initWithFrame:(CGRect)laFrame {
	return [self initWithOrigin:laFrame.origin];
}

- (id) initWithOrigin:(CGPoint)laPoint {
	self = [super init];
	if (self) {
		currentContentSizeIdentifier = contentSizeIdentifierForCurrentInterface();
        adButtonType = JPAdvertisementAdImageButton;
		CGSize viewSize = [self sizeFromBannerContentSizeIdentifier:currentContentSizeIdentifier];
		self.view.frame = (CGRect) {laPoint, viewSize};
		
		UIButton *button = [[UIButton alloc] initWithFrame:(CGRect) {CGPointZero, viewSize}];
		self.adButton = button;
		[self.adButton addTarget:self action:@selector(adTapped:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:adButton];
	}
	return self;
}

- (id) initWithWebView:(NSString*)adViewURL{
	return [self initWithWebView:adViewURL adViewSize:adWebViewNormalSize adButtonText:adButtonNormalText];
}

- (id) initWithWebView:(NSString*)adViewURL adViewSize:(CGSize)adViewSize{
	return [self initWithWebView:adViewURL adViewSize:adViewSize adButtonText:adButtonNormalText];
}

- (id) initWithWebView:(NSString*)adViewURL adButtonText:(NSString*)adButtonText{
	return [self initWithWebView:adViewURL adViewSize:adWebViewNormalSize adButtonText:adButtonText];
}

- (id) initWithWebView:(NSString*)adViewURL adViewSize:(CGSize)adViewSize adButtonText:(NSString*)adButtonText{
	self = [super init];
	if (self) {
		currentContentSizeIdentifier = contentSizeIdentifierForCurrentInterface();
        self.adButtonType = JPAdvertisementAdNormalButton;
        self.adWebViewSize = adViewSize;
        self.adViewButtonText = adButtonText;
        self.adWebViewURL = adViewURL;
        
		CGSize viewSize = [self sizeFromBannerContentSizeIdentifier:currentContentSizeIdentifier];
		self.view.frame = (CGRect) {CGPointZero, viewSize};
		
		UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = (CGRect) {CGPointZero, viewSize};
        self.adButton = button;
		[self.adButton addTarget:self action:@selector(adTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.adButton setTitle:adButtonText forState:UIControlStateNormal];
		[self.view addSubview:adButton];
        
        self.adWebViewLoaded = FALSE;
	}
	return self;
}

#pragma mark - Dealloc

- (void)dealloc {
	adButton = nil;
    adWebView = nil;
    adWebBackgroundView = nil;
	adURL = nil;
	linkShareURL = nil;
	
	adImagePortrait = nil;
	adImageLandscape = nil;
	
	adClicked = nil;
	clickThroughFailed = nil;
}

#pragma mark - View lifecycle

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (NSString *) description {
	if (self.affiliatedLink) {
		return [NSString stringWithFormat:@"%@ with affiliated link: %@", [super description], self.linkShareURL];
	} else {
		return [NSString stringWithFormat:@"%@ with ad URL: %@", [super description], self.adURL];
	}
	
	
	return [NSString stringWithFormat:@"%@ with ad URL: %@, linkshare URL: %@ and isAffiliate:%@", [super description], self.adURL, self.linkShareURL, (self.affiliatedLink ? @"NO" : @"YES")];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.autoresizingMask = (UIViewAutoresizingNone);
	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceRotated:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
	
	[self deviceRotated:self];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (void) viewDidAppear:(BOOL)animated {
	[self layoutAdForCurrentOrientation];
}

#pragma mark - Multiple Orientation Support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


- (void) layoutAdForCurrentOrientation {
    if (adButtonType == JPAdvertisementAdImageButton) {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        UIImage *adImage = nil;
        
        if (UIInterfaceOrientationIsPortrait(orientation))
            adImage = [UIImage imageNamed:adImagePortrait];
        else if (UIInterfaceOrientationIsLandscape(orientation))
            adImage = [UIImage imageNamed:adImageLandscape];
        
        currentContentSizeIdentifier = contentSizeIdentifierForCurrentInterface();
        [self.adButton setImage:adImage forState:UIControlStateNormal];
        
        [self.adButton setNeedsDisplay];
    }else {
        currentContentSizeIdentifier = contentSizeIdentifierForCurrentInterface();
    }
}

- (void) deviceRotated:(id) sender {
	
	[self layoutAdForCurrentOrientation];
	
	CGSize size = [self sizeFromBannerContentSizeIdentifier:currentContentSizeIdentifier];
	CGRect newFrame = {0,0, size};
	CGRect newAdWebBackgroundViewFrame = [self adWebBackgroundViewRectForCurrentInterface:currentContentSizeIdentifier];
    CGRect newAdWebViewFrame = (CGRect){[self adWebViewPointForCurrentInterface:currentContentSizeIdentifier adWebViewSize:self.adWebViewSize], self.adWebViewSize};
    
    
	[UIView animateWithDuration:0.2 animations:^(void) {
        self.frame = newAdWebBackgroundViewFrame;
		self.view.frame = (CGRect) {self.view.frame.origin, size};
		self.adButton.frame = newFrame;
        
        if (self.adWebViewLoaded){
            self.adWebView.frame = newAdWebViewFrame;
            self.adWebBackgroundView.frame = newAdWebBackgroundViewFrame;
         }

	}];
}

@end
