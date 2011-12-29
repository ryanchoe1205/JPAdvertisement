JPAdvertisement
=============

JPAdvertisementBannerViewController is a near drop in replacement for `ADBannerView`. Meant as a local/cached version of iAds. Ads are loaded from homemade `.plist` files, an example ad for Grades 2 http://gradesapp.com is included and used in the demo project.

## Use

To use JPAdvertisement copy the JPAdvertisementBannerViewController class from the JPAdvert folder. Include in your Copy Bundle Resources the plist and image files for you advertisement.

Documentation is available at http://joepasq.com/documentation/jpadvertisement/

## Custom Ads

In order to load an ad from disk JPAdvertisement uses a plist, the name of which is passed to it via `loadAdFromPlistNamed:`. In that plist it looks for four keys; the adURL, affiliatedLink boolean, and file names of png images for landscape and portrait ads. See the Grades Sample Ad folder and mimic that to make your own ads.

The images specified in the plist are just the base name; for example `GradesLandscape.png` and `GradesPortrait.png`. In the directory though are 4x as many files; `GradesPortrait~iphone`, `GradesPortrait@2x~iphone`, `GradesPortrait~ipad`, `GradesPortrait@2x~ipad`, `GradesLandscape~iphone`, `GradesLandscape@2x~iphone`, `GradesLandscape~ipad` and `GradesLandscape@2x~ipad`. The correct one is loaded automatically by `UIimage` (see [Resource documetnation](https://developer.apple.com/library/ios/#documentation/Cocoa/Conceptual/LoadingResources/Introduction/Introduction.html) device specific resources). 

## Image Resources
 
If you include @2x retina images and non-retina images, `UIImage` will load the correct resource for the correct resolution. If you include iPad and iPhone resources they should all have the same file name but end with a tilde and the device name in lowercase.
 
Example files:

* AdvertLandscape~ipad.png
* AdvertLandscape~iphone.png
* AdvertLandscape@2x-iphone.png
 
Will all be recorded in the advertisement `.plist` as `AdvertLandscape.png`. As shown here: <img src="http://joepasq.com/documentation/resources/gradessamplead.png" alt="http://joepasq.com/documentation/resources/gradessamplead.png" title="Grades_appstore.plist"/>
 