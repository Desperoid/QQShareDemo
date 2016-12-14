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
@interface ShareViewController ()<QQShareManagerDelegate>
@end

@implementation ShareViewController

-(void)dealloc
{
   [[QQShareManager shareInstance] removeListener:self];
}

- (void)viewDidLoad {
   [super viewDidLoad];
   [[QQShareManager shareInstance] addListener:self];
   UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"finished" style:UIBarButtonItemStyleDone target:self action:@selector(resignAllFirstResponeder)];
   self.navigationItem.rightBarButtonItems = @[buttonItem];
   self.DesTextView.layer.borderColor = self.contentTextView.layer.borderColor =
   self.URLTextView.layer.borderColor = [UIColor blackColor].CGColor;
   self.DesTextView.layer.borderWidth = self.contentTextView.layer.borderWidth =
   self.URLTextView.layer.borderWidth = .5f;
    // Do any additional setup after loading the view.
}

#pragma mark - target function
- (IBAction)shareToQzone:(UIButton *)sender
{
   switch (self.shareType) {
      case ShareTypeText:
         [self shareTextMessagePlatForm:QQPlatformQZone];
         break;
      case ShareTypeImage:
         [self shareImageMessagePlatForm:QQPlatformQZone];
         break;
      case ShareTypeImagesToFavorite:
         [self shareImagesToFavorite];
         break;
      case ShareTypeURL:
         [self shareURLPlatForm:QQPlatformQZone];
         break;
      case ShareTypeMusic:
         [self shareMusicPlatForm:QQPlatformQZone];
         break;
      case ShareTypeFile:
         [self shareFile];
      default:
         break;
   }
}
- (IBAction)shareToQQ:(UIButton *)sender
{
   switch (self.shareType) {
      case ShareTypeText:
         [self shareTextMessagePlatForm:QQPlatformQQ];
         break;
      case ShareTypeImage:
         [self shareImageMessagePlatForm:QQPlatformQQ];
         break;
      case ShareTypeImagesToFavorite:
         [self shareImagesToFavorite];
         break;
      case ShareTypeURL:
         [self shareURLPlatForm:QQPlatformQQ];
         break;
      case ShareTypeMusic:
         [self shareMusicPlatForm:QQPlatformQQ];
         break;
      case ShareTypeFile:
         [self shareFile];
      default:
         break;
   }
}

#pragma mark - QQShareManagerDelegate
- (void)onQQShareShareResult:(QQShareManagerResult)result error:(NSError *)error
{
   NSString *resultString;
   if (result == QQShareManagerResultSuccess) {
      resultString = @"分享成功";
   }
   else {
      resultString = @"分享失败";
   }
   UIAlertController *controller = [UIAlertController alertControllerWithTitle:resultString message:error.userInfo[@"errorDescription"] preferredStyle:UIAlertControllerStyleAlert ];
   UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      [controller dismissViewControllerAnimated:YES completion:nil];
   }];
   [controller addAction:action];
   [self presentViewController:controller animated:NO completion:nil];
}

#pragma mark - private funtion
- (void)resignAllFirstResponeder
{
   [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (void)shareTextMessagePlatForm:(QQPlatform)platform
{
   [[QQShareManager shareInstance] shareTextMessage:self.contentTextView.text toPlatform:platform];
}

- (void)shareImageMessagePlatForm:(QQPlatform)platform
{
   NSURL *imageURL = [[NSBundle mainBundle] URLForResource:@"vulcan" withExtension:@"png"];
   NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
   NSData *imageData1 = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"vulcan-1" withExtension:@"jpg"]];
   NSData *imageData2 = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"vulcan-2" withExtension:@"JPG"]];
   [[QQShareManager shareInstance] shareImageDatas:@[imageData1, imageData2, imageData] preivewImageData:imageData title:@"vulcan" description:@"阿斯顿·马丁Vulcan充满赛车气息的车身里大量参考了传奇车型ONE-77的图纸，尽管官方并没有明确写出Vulcan与ONE-77的关系，但实际上Vulcan就可以被看作为终极版的ONE-77，采用碳纤维车身、前中置后驱布局、推杆式悬挂系统、后轮345/30 R19规格的米其林竞赛轮胎、7.0升V12自然吸气发动机(最大功率超过800马力)、6速序列式变速器。" toPlatform:platform];
}

- (void)shareImagesToFavorite
{
   NSURL *imageURL = [[NSBundle mainBundle] URLForResource:@"vulcan" withExtension:@"png"];
   NSData *imageData  = [NSData dataWithContentsOfURL:imageURL];
   NSData *imageData1 = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"vulcan-1" withExtension:@"jpg"]];
   NSData *imageData2 = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"vulcan-2" withExtension:@"JPG"]];
   NSArray *imageDataArray = @[imageData, imageData1, imageData2];
   [[QQShareManager shareInstance] shareToQQFavoritesWithImagesData:imageDataArray previewImageData:imageData title:@"vulcan" description:@"阿斯顿·马丁Vulcan"];
}

- (void)shareURLPlatForm:(QQPlatform)platform
{
   NSURL *imageURL = [[NSBundle mainBundle] URLForResource:@"vulcan" withExtension:@"png"];
   [[QQShareManager shareInstance] shareURL:[NSURL URLWithString:@"http://www.autohome.com.cn/3730/6797/"] previewImageURL:imageURL title:@"vulcan" description:@"阿斯顿·马丁Vulcan" toQQPlatform:platform];
}

- (void)shareMusicPlatForm:(QQPlatform)platform
{
   NSURL *MusicURL = [NSURL URLWithString:@"http://music.163.com/song/426881506/?userid=20369675"];
   NSURL *flashURL = [NSURL URLWithString:@"http://183.57.28.34/m10.music.126.net/20161212120138/05e605c85097248a2e447089ffdbed88/ymusic/1709/eb2a/f3c3/3e2dbbf1abf1469a7e635b0dd45aa402.mp3?wshc_tag=1&wsts_tag=584e1b46&wsid_tag=3b2466f7&wsiphost=ipdbm"];
   NSURL *imageURL = [NSURL URLWithString:@"http://p4.music.126.net/sSxbRt9RpC6s_MaewyDJfA==/18597139672292692.jpg?param=34y34"];
   [[QQShareManager shareInstance] shareMusicURL:MusicURL preivewImageURL:imageURL flashURL:flashURL title:@"なんでもないや" description:@"你的名字" toQQPlatform:platform];
}

- (void)shareFile
{
   NSString *filePath = [[NSBundle mainBundle] pathForResource:@"vulcan" ofType:@"png"];
   NSData *imageDate = [NSData dataWithContentsOfFile:filePath];
   [[QQShareManager shareInstance] shareToQQWithFilePath:filePath fileName:@"vulcan.png" preiviewImageData:imageDate title:@"vulcan" description:@"阿斯顿马丁vulcan"];
}
@end
