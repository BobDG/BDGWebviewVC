//
//  BDGWebviewVC.h
//
//  Created by Bob de Graaf on 22-02-11.
//  Copyright 2011 GraafICT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class BDGWebviewVC;

@protocol BDGWebviewVCDelegate <NSObject>
@optional
-(void)purchaseIAS:(NSString *)appStoreID;
-(void)WVCdismissed:(BDGWebviewVC *)webviewVC;
@end

@interface BDGWebviewVC : UIViewController
{
    
}

-(void)openSafari;
-(void)nextWebpage;
-(void)previousWebPage;

@property(nonatomic,assign) id<BDGWebviewVCDelegate> delegate;
@property(nonatomic) UIBarStyle barStyle;

@property(nonatomic,retain) NSString *urlStr;
@property(nonatomic,retain) NSString *htmlStr;
@property(nonatomic,retain) NSString *navTitle;
@property(nonatomic,retain) NSString *mailBody;
@property(nonatomic,retain) NSString *appStoreID;
@property(nonatomic,retain) NSString *mailSubject;
@property(nonatomic,retain) NSString *mailToAddress;
@property(nonatomic,strong) NSString *mailPopupText;

@property(nonatomic,retain) UIViewController *parent;
@property(nonatomic,strong) NSMutableDictionary *headersDict;

@property(nonatomic) int buttonDelay;
@property(nonatomic) bool hideButtons;
@property(nonatomic) bool fullRotation;
@property(nonatomic) bool alwaysReload;
@property(nonatomic) bool popAfterLeaving;

@end