//
//  JPAdvertisementPlaygroundViewController.m
//  JPAdvertisement
//
//  Created by Joe on 5/12/11.
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

#import "JPStandInViewController.h"

@implementation JPStandInViewController

@synthesize adViewC;


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    [adViewC didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];

//    self.adViewC = [[JPAdvertisementBannerViewController alloc] initWithWebView:@"http://s5.b51hosting.com/kai/tmp/ios_ad.html"];
    
    self.adViewC = [[JPAdvertisementBannerViewController alloc] initWithWebView:@"http://s5.b51hosting.com/kai/tmp/ios_ad.html" adViewSize:(CGSize){300, 250} adButtonText:@"Show AD"];
    adViewC.adView_WillAppear = ^(void) {
        NSLog(@"Opening AD Web Page");
    };
    adViewC.adView_WillDisappear = ^(void) {
        NSLog(@"Closing AD Web Page");
    };
    
    adViewC.adClicked = ^(void) {
        NSLog(@"Clicked AD");	
    };
    
	[self.view addSubview:adViewC.view];
}


- (void) viewWillAppear:(BOOL)animated {
	[adViewC loadAd];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
										 duration:(NSTimeInterval)duration {
//    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
//	{
//		banner.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
//	}
//	else
//	{
//		banner.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
//	}
}


@end
