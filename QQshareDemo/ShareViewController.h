//
//  ShareViewController.h
//  QQshareDemo
//
//  Created by Geng on 2016/12/9.
//  Copyright © 2016年 Geng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *TitleTextField;
@property (weak, nonatomic) IBOutlet UITextView *DesTextView;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UITextView *URLTextView;

@end
