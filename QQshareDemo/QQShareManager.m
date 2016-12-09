//
//  QQShareManager.m
//  QQshareDemo
//
//  Created by Geng on 2016/12/9.
//  Copyright © 2016年 Geng. All rights reserved.
//

#import "QQShareManager.h"

static NSString *const QQAppId = @"1105800529";

@interface QQShareManager ()
@property (nonatomic, strong) TencentOAuth *tencentOAuth;
@end

@implementation QQShareManager
+(void)load
{
   [self shareInstance];
}

#pragma mark - life circle

+(instancetype)shareInstance
{
   static QQShareManager *_instance;
   static dispatch_once_t onceToken;
   dispatch_once(&onceToken, ^{
      _instance = [[[self class] alloc] initPrivate];
      _instance.tencentOAuth = [[TencentOAuth alloc] initWithAppId:QQAppId andDelegate:_instance];
   });
   
   return _instance;
}

- (instancetype)init
{
   return [[self class] shareInstance];
}

- (instancetype)initPrivate
{
   if (self = [super init]) {
      
   }
   return self;
}

#pragma mark - public fcuntion
- (void)shareToQQWithTextMessage:(NSString *)text
{

   QQApiTextObject *txtObj = [QQApiTextObject objectWithText:text];
   SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:txtObj];
   QQApiSendResultCode sent = [QQApiInterface sendReq:req];
#pragma unused(sent)
}

- (void)shareToQQWithImageData:(NSData *)imageData
              preivewImageData:(NSData *)previewImageData
                         title:(NSString *)title
                   description:(NSString *)description
{
   QQApiImageObject *imageObj = [QQApiImageObject objectWithData:imageData previewImageData:previewImageData title:title description:description];
   SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:imageObj];
   QQApiSendResultCode sent = [QQApiInterface sendReq:req];
#pragma unused(sent)
}

- (void)shareToQQFavoritesWithImagesData:(NSArray<NSData *> *)imagesData
                        previewImageData:(NSData *)previewImageData
                                   title:(NSString *)title
                             description:(NSString *)description
{
   QQApiImageObject *imgObj = [QQApiImageObject objectWithData:previewImageData previewImageData:previewImageData title:title description:description imageDataArray:imagesData];
   [imgObj setCflag:kQQAPICtrlFlagQQShareFavorites];
   SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:imgObj];
   QQApiSendResultCode sent = [QQApiInterface sendReq:req];
#pragma unused(sent)
}

- (void)shareToQQWithFilePath:(NSString *)filePath
                     fileName:(NSString *)fileName
            preiviewImageData:(NSData *)imageData
                        title:(NSString *)title
                  description:(NSString *)description
{
   NSData *fileData = [NSData dataWithContentsOfFile:filePath];
   QQApiFileObject *fileObj = [QQApiFileObject objectWithData:fileData previewImageData:imageData title:title description:description];
   fileObj.fileName = fileName;
   [fileObj setCflag:kQQAPICtrlFlagQQShareDataline];
   SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:fileObj];
   QQApiSendResultCode sent = [QQApiInterface sendReq:req];
#pragma unused(sent)
}

- (void)shareMusicURL:(NSURL *)url
      preivewImageURL:(NSURL *)imageURL
             flashURL:(NSURL *)flashURL
                title:(NSString *)title
          description:(NSString *)description
         toQQPlatform:(QQPlatform)platform
{
   QQApiAudioObject *audioObj = [QQApiAudioObject objectWithURL:url title:title description:description previewImageURL:imageURL];
   [audioObj setFlashURL:flashURL];
   SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:audioObj];
   QQApiSendResultCode sent;
   if (platform == QQPlatformQQ) {
      sent = [QQApiInterface sendReq:req];
   }
   else if (platform == QQPlatformQZone) {
      sent = [QQApiInterface SendReqToQZone:req];
   }
   
}

- (void)shareURL:(NSURL *)url previewImageURL:(NSURL *)imageURL title:(NSString *)title description:(NSString *)description toQQPlatform:(QQPlatform)platform
{
   QQApiNewsObject *newsObj = [QQApiNewsObject objectWithURL:url title:title description:description previewImageURL:imageURL];
   SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
   QQApiSendResultCode sent;
   if (platform == QQPlatformQQ) {
      sent = [QQApiInterface sendReq:req];
   }
   else if (platform == QQPlatformQZone) {
      sent = [QQApiInterface SendReqToQZone:req];
   }
}

#pragma mark - TencentLoginDelegate
-(void)tencentDidLogin
{
   
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
   
}

- (void)tencentDidNotNetWork
{
   
}

#pragma mark - TencentApiInterfaceDelegate
- (void)onResp:(QQBaseResp *)resp
{
   
}
#pragma mark - TencentSessionDelegate
//分享到QZone回调
- (void)addShareResponse:(APIResponse*) response
{
   
}

- (void)responseDidReceived:(APIResponse*)response forMessage:(NSString *)message
{
   
}
@end
