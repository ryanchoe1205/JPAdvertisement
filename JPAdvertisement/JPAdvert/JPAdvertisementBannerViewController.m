//
//  JPAdvertisementBannerViewController.m
//  JPAdvertisement
//
//  Created by Joe on 4/26/11.
/*
 
 http://joepasq.com 
 https://github.com/joepasq
 
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

CGSize handheldPortraitSize = {320, 50};
CGSize handheldLandscape = {480, 32};

CGSize tabletPortraitSize = {768, 66};
CGSize tabletLandscapeSize = {1024, 66};

static NSString *contentSizeIdentifierForCurrentInterface() {
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] userInterfaceIdiom];
	
	if (UIInterfaceOrientationIsPortrait(orientation)) {
		if (idiom == UIUserInterfaceIdiomPhone)
			return JPAdvertisementHandheldPortrait;
		else if (idiom == UIUserInterfaceIdiomPad)
			return JPAdvertisementTabletPortrait;
	} else if (UIInterfaceOrientationIsLandscape(orientation)) {
		if (idiom == UIUserInterfaceIdiomPhone)
			return JPAdvertisementHandheldLandscape;
		else if (idiom == UIUserInterfaceIdiomPad)
			return JPAdvertisementTabletLandscape;
	}
	return nil;
}

@interface JPAdvertisementBannerViewController ()

- (void) deviceRotated:(id) sender;

- (void)openReferralURL:(NSURL *)referralURL;
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

- (void) layoutAdForCurrentOrientation;

@end;


@implementation JPAdvertisementBannerViewController

@synthesize adButton;

@synthesize adURL, linkShareURL;
@synthesize affiliatedLink;

@synthesize adImagePortrait, adImageLandscape;

@synthesize requiredContentSizeIdentifiers, currentContentSizeIdentifier;

@synthesize hidden, frame;


#pragma mark - Ad Loading

- (BOOL) loadAdFromPlistNamed:(NSString *) plist {
	
	NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:plist ofType:@"plist"]];
	
	BOOL completeData = YES;
	
	//check for all data keys to have a real value
	//	for (NSString *key in [data allKeys]) {
	//		if (nil == [data valueForKey:key]) {
	//			completeData = NO;
	//		}
	//	}
	
	if (completeData) {
		self.adURL = [NSURL URLWithString:[data valueForKey:@"adURL"]];
		self.affiliatedLink = [data valueForKey:@"affiliatedLink"] ? YES : NO;
		
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
			self.adImageLandscape = [data valueForKey:@"handheldLandscapeImage"];
			self.adImagePortrait = [data valueForKey:@"handheldPortraitImage"];
		} else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
			self.adImageLandscape = [data valueForKey:@"tabletLandscapeImage"];
			self.adImagePortrait = [data valueForKey:@"tabletPortraitImage"];
		}
		
		[self layoutAdForCurrentOrientation];
		return YES;
	} else
		return NO;
}

- (BOOL) loadAd {
	return [self loadAdFromPlistNamed:@"Grades"];
}


#pragma mark - UI

- (IBAction) adTapped:(UIButton *) sender {
	if (affiliatedLink) {
		[self openReferralURL:adURL];
	} else
		[[UIApplication sharedApplication] openURL:adURL];
}

+ (CGSize) sizeFromBannerContentSizeIdentifier:(NSString *)contentSizeIdentifier {
	if (contentSizeIdentifier == JPAdvertisementHandheldLandscape) {
		return handheldLandscape;
	} else if (contentSizeIdentifier == JPAdvertisementHandheldPortrait) {
		return handheldPortraitSize;
	} else if (contentSizeIdentifier == JPAdvertisementTabletLandscape) {
		return tabletLandscapeSize;
	} else if (contentSizeIdentifier == JPAdvertisementTabletPortrait) {
		return tabletPortraitSize;
	} else
		return CGSizeZero;
}

- (CGSize) sizeFromBannerContentSizeIdentifier:(NSString *)contentSizeIdentifier {
	return [JPAdvertisementBannerViewController sizeFromBannerContentSizeIdentifier:contentSizeIdentifier];
}

#pragma mark - LinkShare

// Process a LinkShare/TradeDoubler/DGM URL to something iPhone can handle
- (void)openReferralURL:(NSURL *)referralURL {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:adURL] delegate:self startImmediately:YES];
    [conn release];
}

// Save the most recent URL in case multiple redirects occur
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    self.linkShareURL = [response URL];
    return request;
}

// No more redirects; use the last URL saved
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [[UIApplication sharedApplication] openURL:self.linkShareURL];
}

#pragma mark - UIView methods

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

#pragma mark - Memory Management

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
		CGSize viewSize = [self sizeFromBannerContentSizeIdentifier:currentContentSizeIdentifier];
		self.view.frame = (CGRect) {laPoint, viewSize};
		
		UIButton *button = [[UIButton alloc] initWithFrame:(CGRect) {CGPointZero, viewSize}];
		self.adButton = button;
		[self.adButton addTarget:self action:@selector(adTapped:) forControlEvents:UIControlEventTouchUpInside];
		[button release];
		[self.view addSubview:adButton];
	}
	return self;
}


- (void)dealloc {
	[adButton release], adButton = nil;
	[adURL release];
	[linkShareURL release];
	
	[adImagePortrait release], [adImageLandscape release];
	
	[requiredContentSizeIdentifiers release];
	[currentContentSizeIdentifier release];
	
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



#pragma mark - View lifecycle

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


- (void) layoutAdForCurrentOrientation {
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	UIImage *adImage = nil;
	
	if (UIInterfaceOrientationIsPortrait(orientation))
		adImage = [UIImage imageNamed:adImagePortrait];
	else if (UIInterfaceOrientationIsLandscape(orientation))
		adImage = [UIImage imageNamed:adImageLandscape];
	
	currentContentSizeIdentifier = contentSizeIdentifierForCurrentInterface();
	[self.adButton setImage:adImage forState:UIControlStateNormal];
	
	[self.adButton setNeedsDisplay];
}


- (void) deviceRotated:(id) sender {
	
	[self layoutAdForCurrentOrientation];
	
	CGSize size = [self sizeFromBannerContentSizeIdentifier:currentContentSizeIdentifier];
	CGRect newFrame = {0,0, size};
	
	[UIView animateWithDuration:0.2 animations:^(void) {
		self.view.frame = (CGRect) {self.view.frame.origin, size};
		self.adButton.frame = newFrame;
	}];
}

@end
