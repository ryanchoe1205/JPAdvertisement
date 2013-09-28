static NSString *const JPAdvertisementHandheldLandscape = @"JPAdvertisementHandheldLandscape";
static NSString *const JPAdvertisementHandheldPortrait = @"JPAdvertisementHandheldPortrait";

static NSString *const JPAdvertisementTabletLandscape = @"JPAdvertisementTabletLandscape";
static NSString *const JPAdvertisementTabletPortrait = @"JPAdvertisementTabletPortrait";
static NSString *const JPAdvertisementAdImageButton = @"JPAdvertisementAdImageButton";
static NSString *const JPAdvertisementAdNormalButton = @"JPAdvertisementAdNormalButton";

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

static CGSize handheldPortraitSize = {320, 480};
static CGSize handheldLandscapeSize = {480, 320};

static CGSize tabletPortraitSize = {768, 1024};
static CGSize tabletLandscapeSize = {1024, 768};