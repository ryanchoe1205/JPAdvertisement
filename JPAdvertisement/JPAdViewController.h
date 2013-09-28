//
//  JPAdViewController.h
//  JPAdvertisement
//
//  Created by Leonardo Redmond on 9/27/13.
//  Copyright (c) 2013 IdiogenicOsmoles & PasquaLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPAdvertisementConstants.h"

@protocol JPAdViewControllerDelegate;

@interface JPAdViewController : UIViewController<UIWebViewDelegate>{
    
@private
    IBOutlet UIButton *adWebViewCloseButton;
    
    CGSize adWebViewSize;
@public
    NSString *currentContentSizeIdentifier;
}

@property (nonatomic, weak) id<JPAdViewControllerDelegate> delegate;

@property (nonatomic, strong) UIWebView *adWebView;
@property (nonatomic, strong) UIView *adWebBackgroundView;
@property (nonatomic, strong) UIButton *adWebViewCloseButton;

@property (nonatomic, copy) NSString *currentContentSizeIdentifier;
@property (nonatomic) CGSize adWebViewSize;

+ (CGRect) adWebViewRectForCurrentInterface:(NSString *)contentSizeIdentifier adWebViewSize:(CGSize) adWebViewSize;
- (CGRect) adWebViewRectForCurrentInterface:(NSString *)contentSizeIdentifier adWebViewSize:(CGSize) adWebViewSize;

- (id) initWith:(CGSize)viewSize adWebViewURL:(NSString*)adWebViewURL;

@end

@protocol JPAdViewControllerDelegate <NSObject>

-(void)adView_BeforeClose;
-(void)adView_AfterClose;
-(void)adView_Tapped:(NSURL*)adURL;
@end