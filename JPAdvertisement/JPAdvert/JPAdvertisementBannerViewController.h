//
//  JPAdvertisementBannerViewController.h
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

#import <UIKit/UIKit.h>

static NSString *const JPAdvertisementHandheldLandscape = @"JPAdvertisementHandheldLandscape";
static NSString *const JPAdvertisementHandheldPortrait = @"JPAdvertisementHandheldPortrait";

static NSString *const JPAdvertisementTabletLandscape = @"JPAdvertisementTabletLandscape";
static NSString *const JPAdvertisementTabletPortrait = @"JPAdvertisementTabletPortrait";

typedef void (^AdvertisementVoidBlock) (void);

/** JPAdvertisementBannerViewController is a near drop in replacement for ADBannerView. Meant as a local/cached version of iAds. Ads are loaded from self made .plist files, an example ad for Grades 2 http://gradesapp.com is included and used in the demo project.
 
 To use JPAdvertisement copy the JPAdvertisementBannerViewController class from the JPAdvert folder. Include in your Copy Bundle Resources the plist and image files for you advertisement.
  
 In order to load an ad from disk JPAdvertisement uses a plist, the name of which is passed to it via loadAdFromPlistNamed:. In that plist it looks for four keys; the adURL, affiliatedLink boolean, and file names of png images for landscape and portrait ads depending upon what device it is currently running on. See the Grades Sample Ad folder and mimic that to make your own ads.
 */ 
@interface JPAdvertisementBannerViewController : UIViewController {
@private
	IBOutlet UIButton *adButton;
	
	NSURL *adURL, *linkShareURL;
	BOOL affiliatedLink;
	
	NSString *adImageLandscape, *adImagePortrait;
	
@public
	NSSet *requiredContentSizeIdentifiers;
	NSString *currentContentSizeIdentifier;
	
	BOOL hidden;
	CGRect frame;
}

/** @name User Interface */
/** The button shown to the user that takes up all the entire view's frame. */
@property (nonatomic, retain) UIButton *adButton;

/** @name URLs */
/** The advertisement URL. Read from loaded plist.
 
 If affiliated, then NSURLConnection loads the actual ad URL into linkShareURL.
 If not affiliated, then this URL is opened directly. */
@property (nonatomic, copy) NSURL *adURL;
/** If adURL is an affiliated link, this is used to store the actual URL once LinkShare registers the 'click'. */
@property (nonatomic, copy) NSURL *linkShareURL;
/** Determines whether the URL is loaded through a background NSURLConnection to process affiliated links or it if launches whatever service it uses directly. */
@property (nonatomic, assign) BOOL affiliatedLink;

/** @name Advertisement Image */
/** Landcsape advertisement image loaded from plist in appropriate size depending on device.Loads retina scale image is loaded if available and on a retina device.
 
 For tablets this must be 1024 x 66. For handhelds this must be 480 x 32. */
@property (nonatomic, copy) NSString *adImageLandscape;
/** Portrait advertisement image loaded from plist in appropriate size depending on device. Loads retina scale image is loaded if available and on a retina device.
 
 For tablets this must be 768 x 66. For handhelds this must be 320 x 50. 
 */
@property (nonatomic, copy) NSString *adImagePortrait;

/** @name Advertisement Size */
/** Mimics iAd. See ADBannerView. */
@property (nonatomic, copy) NSSet *requiredContentSizeIdentifiers;
@property (nonatomic, copy) NSString *currentContentSizeIdentifier;

/** @name Delegate Blocks */
/** Calls adClicked when a plain URL ad is opened or when an affiliated link is done registering and then opened. */
@property (nonatomic, copy) AdvertisementVoidBlock adClicked;
/** Calls clickThroughFailed when a plain URL cannot open (Safari blocked) or when an affiliated link does not open (LinkShare down, possibly?). */
@property (nonatomic, copy) AdvertisementVoidBlock clickThroughFailed;

/** @name Exposed UIView Methods */
/** Exposes the hidden property of the view ivar to mimic the way ADBannerView works. */
@property (nonatomic, getter = isHidden) BOOL hidden;
/** Exposes the frame property of the view ivar to mimic the way ADBannerView works. */
@property (nonatomic) CGRect frame;

/** @name Ad Sizes */
/** contentSizeIdentifier can be JPAdvertisementHandheldLandscape, JPAdvertisementHandheldPortrait, JPAdvertisementTabletLandscape or JPAdvertisementTabletPortrait.
 @return A CGSize describing two of the following: handheld OR tablet AND portrait OR landscape all depending on the current device.
 @param contentSizeIdentifier constant size identifier declared in this header file.*/
+ (CGSize) sizeFromBannerContentSizeIdentifier:(NSString *)contentSizeIdentifier;
- (CGSize) sizeFromBannerContentSizeIdentifier:(NSString *)contentSizeIdentifier;

/** @name Loading Compiled-in Ads */
/** Load ad called loadAdFromPlistNamed: using the Grades ad. */
- (BOOL) loadAd;

/** Loads an ad from a property list.
 
 The plist is opened for the keys:
 adURL - NSString
 affiliatedLink - BOOL
 
 If the current device has the userInterfaceIdiom UIUserInterfaceIdiomPhone then these image name keys are loaded:
 handheldLandscapeImage - NSString
 handheldPortraitImage - NSString
 
 If the current device has the userInterfaceIdiom UIUserInterfaceIdiomPad then these image name keys are loaded:
 tabletLandscapeImage - NSString
 tabletPortraitImage - NSString 
 
 A single plist file can hold both handheld and tablet keys, only the relevant ones will be asked for as appropriate for the current device.
 
 @warning Retina scale (double resolution) images will be loaded automatically, do not specify @2x in the image name in order to ensure compatibility with non-retina devices. 
 
 @return YES if the plist loaded is not nil, otherwise no.
 @param plist is the name of a property list file bundled with the application storing the keys described in this method description.
 */
- (BOOL) loadAdFromPlistNamed:(NSString *) plist;

/** @name Ad Clicked */
/** Called when a JPAdvertisementBannerViewController is tapped.
 
 The adURL is then opened, with LinkShare URLs being processed properly so that they open directly instead of redirecting to Safari.
 @param sender the button sending this message. */
- (void) adTapped:(UIButton *) sender;

/** @name Initalizers */
- (id) initWithFrame:(CGRect) frame;
- (id) initWithOrigin:(CGPoint) point;

@end
