//
//  BDGWebviewVC.m
//
//  Created by Bob de Graaf on 22-02-11.
//  Copyright 2011 GraafICT. All rights reserved.
//

#import "BDGWebviewVC.h"

@interface BDGWebviewVC () <MFMailComposeViewControllerDelegate, UIWebViewDelegate>
{
    UIButton *closeButton;
    UIButton *backButton;
    UIButton *forwButton;
    UIButton *mailButton;
    UIButton *safaButton;
}

@property(nonatomic,strong) UIWebView *web;

@end

@implementation BDGWebviewVC

#pragma mark Load/Appear methods

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    //navigation item
    if(self.navTitle.length>0) {
        self.title = self.navTitle;
    }
    
    //Add CloseButton
    if(self.navigationController.viewControllers.count==1) {
        //close button
        closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(0, 0, 24, 24);
        closeButton.showsTouchWhenHighlighted = TRUE;
        [closeButton setImage:[UIImage imageNamed:@"WVC_Exit.png"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    }
    
    //webview
    _web = [[UIWebView alloc] initWithFrame:CGRectZero];
    self.web.backgroundColor = [UIColor clearColor];
    self.web.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.web.scalesPageToFit = TRUE;
    self.web.delegate = self;
    self.view = self.web;
    
    //Navigation buttons
    if(!self.hideButtons) {
        //back button
        backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(0, 0, 25, 25);
        backButton.showsTouchWhenHighlighted = TRUE;
        [backButton setImage:[UIImage imageNamed:@"WVC_Back.png"] forState:UIControlStateNormal];
        [backButton addTarget:self.web action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        
        //forward button
        forwButton = [UIButton buttonWithType:UIButtonTypeCustom];
        forwButton.frame = CGRectMake(0, 0, 25, 25);
        forwButton.showsTouchWhenHighlighted = TRUE;
        [forwButton setImage:[UIImage imageNamed:@"WVC_Forward.png"] forState:UIControlStateNormal];
        [forwButton addTarget:self.web action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *forwItem = [[UIBarButtonItem alloc] initWithCustomView:forwButton];
        
        //mail button
        mailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        mailButton.frame = CGRectMake(0, 0, 24, 16);
        [mailButton setImage:[UIImage imageNamed:@"WVC_Mail.png"] forState:UIControlStateNormal];
        [mailButton addTarget:self action:@selector(openMail) forControlEvents:UIControlEventTouchUpInside];
        mailButton.showsTouchWhenHighlighted = TRUE;
        UIBarButtonItem *mailItem = [[UIBarButtonItem alloc] initWithCustomView:mailButton];
        
        //safari button
        safaButton = [UIButton buttonWithType:UIButtonTypeCustom];
        safaButton.frame = CGRectMake(0, 0, 24, 24);
        safaButton.showsTouchWhenHighlighted = TRUE;
        [safaButton setImage:[UIImage imageNamed:@"WVC_Safari.png"] forState:UIControlStateNormal];
        [safaButton addTarget:self action:@selector(openSafari) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *safaItem = [[UIBarButtonItem alloc] initWithCustomView:safaButton];
        
        UIBarButtonItem *space1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        UIBarButtonItem *space2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        UIBarButtonItem *space3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        [space1 setWidth:15.0f];
        [space2 setWidth:15.0f];
        [space3 setWidth:15.0f];
        
        self.navigationItem.rightBarButtonItems = @[backItem, space1, forwItem, space2, mailItem, space3, safaItem];
        
        if(self.buttonDelay != 0) {
            backButton.hidden = TRUE;
            forwButton.hidden = TRUE;
            mailButton.hidden = TRUE;
            safaButton.hidden = TRUE;
            closeButton.hidden = TRUE;
            [self performSelector:@selector(setButtonsEnabled) withObject:nil afterDelay:self.buttonDelay];
        }
    }
    else if(self.buttonDelay != 0 && self.navigationController.viewControllers.count==1) {
        closeButton.hidden = TRUE;
        [self performSelector:@selector(setCloseButtonEnabled) withObject:nil afterDelay:self.buttonDelay];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[self performSelector:@selector(loadURL) withObject:nil afterDelay:0.01];
}

-(void)viewWillDisappear:(BOOL)animated
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.web.delegate = nil;
}

#pragma mark Webview methods

-(BOOL)webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType
{
    //First check if we should just open the AppStore/Email
    if(inType == UIWebViewNavigationTypeLinkClicked) {
        if(self.appStoreID.length>0 && [[UIDevice currentDevice] systemVersion].floatValue >= 6.0) {
            if([self.delegate respondsToSelector:@selector(purchaseIAS:)]) {
                [self.delegate purchaseIAS:self.appStoreID];
                return NO;
            }
        }
        else if(self.mailToAddress.length>0) {
            [self openInAppEmail:self.mailSubject mailBody:self.mailBody mailTo:self.mailToAddress isHtml:FALSE];
            return NO;
        }
    }
    
    //Facebook login success check
    if([[[inRequest URL] absoluteString] isEqualToString:@"https://m.facebook.com/plugins/login_success.php"])
	{
		//Open facebook login in ModalViewController
        if(![self.title isEqualToString:NSLocalizedStringFromTable(@"FacebookLogin", @"WVCLocalizable", @"")]) {
            BDGWebviewVC *wvc = [[BDGWebviewVC alloc] init];
            wvc.urlStr = [[inRequest URL] absoluteString];
            wvc.hideButtons = TRUE;
            wvc.parent = self.parent;
            wvc.barStyle = self.barStyle;
            wvc.title = NSLocalizedStringFromTable(@"FacebookLogin", @"WVCLocalizable", @"");
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:wvc];
            [self.parent presentViewController:nav animated:TRUE completion:nil];
            return NO;
        }
        return TRUE;
	}
    
    //Safari check
	if([[[inRequest URL] absoluteString] rangeOfString:@"itunes.apple.com"].location != NSNotFound || [[[inRequest URL] absoluteString] rangeOfString:@"openinsafari"].location != NSNotFound) {
		[[UIApplication sharedApplication] openURL:[inRequest URL]];
        if(self.popAfterLeaving) {
            [self performSelector:@selector(popControllerDelayed) withObject:nil afterDelay:0.5];
        }
        else {
            //Check whether I'm a modal viewcontroller
            if(inType != UIWebViewNavigationTypeLinkClicked && ((self.presentingViewController && self.presentingViewController.presentedViewController == self) || (self.navigationController && self.navigationController.presentingViewController && self.navigationController.presentingViewController.presentedViewController == self.navigationController))) {
                [self dismissViewControllerAnimated:TRUE completion:nil];
            }
        }
		return NO;
	}
    
    //Simple load
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	return YES;
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"BDGWebviewVC: Error loading url: %@, error: %@", self.urlStr.length>0 ? self.urlStr : self.htmlStr, [error description]);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void)webViewDidFinishLoad:(UIWebView *)w
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void)loadURL
{
    if(self.urlStr.length>0) {
        NSURL *url = [NSURL URLWithString:self.urlStr];
        NSMutableURLRequest *requestObj = [NSMutableURLRequest requestWithURL:url];
        [requestObj setAllHTTPHeaderFields:self.headersDict];
        [self.web loadRequest:requestObj];
    }
    else if(self.htmlStr.length>0) {
        [self.web loadHTMLString:self.htmlStr baseURL:nil];
    }
}

#pragma mark Email

-(void)openInAppEmail:(NSString*)subject mailBody:(NSString*)body mailTo:(NSString *)mailTo isHtml:(BOOL)isHtml
{
	@try
	{
		MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
		controller.mailComposeDelegate = self;
		[controller setSubject:subject];
		[controller setMessageBody:body isHTML:isHtml];
        [controller.navigationBar setBarStyle:self.barStyle];
        if(mailTo.length>0) {
            [controller setToRecipients:[NSArray arrayWithObject:mailTo]];
        }
        if(controller != nil) {
            if(self.parent.presentedViewController) {
                [self.parent.presentedViewController presentViewController:controller animated:TRUE completion:nil];
            }
            else {
                [self.parent presentViewController:controller animated:TRUE completion:nil];
            }
        }
	}
	@catch (NSException *e) {
	}
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    if(result == MFMailComposeResultSent) {
        if(self.mailPopupText.length>0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:self.mailPopupText delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"WVCLocalizable", @"") otherButtonTitles:nil];
            [alert show];
        }
    }
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

#pragma mark AlertviewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == 1) {
		[[UIApplication sharedApplication] openURL:self.web.request.URL];
	}
}

#pragma mark Button Actions

-(void)openSafari
{
	UIAlertView *a = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"OpenInSafari", @"WVCLocalizable", @"") message:NSLocalizedStringFromTable(@"OpenInSafariDetails", @"WVCLocalizable", @"") delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"WVCLocalizable", @"") otherButtonTitles:NSLocalizedStringFromTable(@"Yes", @"WVCLocalizable", @""), nil];
	[a show];
}

-(void)openMail
{
	NSString *pag = [self.web.request.URL absoluteString];
	NSString *subject = NSLocalizedStringFromTable(@"PageLink", @"WVCLocalizable", @"");
	[self openInAppEmail:subject mailBody:pag mailTo:nil isHtml:FALSE];
}

-(void)nextWebpage
{
    [self.web goForward];
}

-(void)previousWebPage
{
    [self.web goBack];
}

-(void)done
{
    if([self.delegate respondsToSelector:@selector(WVCdismissed:)]) {
        [self.delegate WVCdismissed:self];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

#pragma mark Misc methods

-(void)setButtonsEnabled
{
    closeButton.hidden = FALSE;
    backButton.hidden = FALSE;
    forwButton.hidden = FALSE;
    mailButton.hidden = FALSE;
    safaButton.hidden = FALSE;
}

-(void)setCloseButtonEnabled
{
    closeButton.hidden = FALSE;
}

-(void)popControllerDelayed
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.navigationController popViewControllerAnimated:FALSE];
}

#pragma mark Rotation

-(NSUInteger)supportedInterfaceOrientations
{
    if(self.fullRotation) {
        return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if(self.fullRotation) {
        return TRUE;
    }
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

#pragma mark Dealloc

-(void)dealloc
{
    [self.web stopLoading];
    self.web.delegate = nil;
    self.web = nil;
    self.parent = nil;
    self.urlStr = nil;
    self.navTitle = nil;
    self.appStoreID = nil;
}

@end





















