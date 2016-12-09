//
//  ShareViewController.m
//  QQshareDemo
//
//  Created by Geng on 2016/12/9.
//  Copyright © 2016年 Geng. All rights reserved.
//

#import "ShareViewController.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "QQShareManager.h"
@interface ShareViewController ()
@end

@implementation ShareViewController

- (void)viewDidLoad {
   [super viewDidLoad];
   [QQShareManager shareInstance];
   UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"finished" style:UIBarButtonItemStyleDone target:self action:@selector(resignAllFirstResponeder)];
   self.navigationItem.rightBarButtonItems = @[buttonItem];
   self.DesTextView.layer.borderColor = self.contentTextView.layer.borderColor =
   self.URLTextView.layer.borderColor = [UIColor blackColor].CGColor;
   self.DesTextView.layer.borderWidth = self.contentTextView.layer.borderWidth =
   self.URLTextView.layer.borderWidth = .5f;
    // Do any additional setup after loading the view.
}
- (void)resignAllFirstResponeder
{
   [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}
- (IBAction)shareToQzone:(UIButton *)sender
{
}
- (IBAction)shareToQQ:(UIButton *)sender
{
   [[QQShareManager shareInstance] shareToQQWithTextMessage:self.contentTextView.text];
}

@end
