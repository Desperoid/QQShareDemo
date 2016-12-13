//
//  QQShareManager.m
//  QQshareDemo
//
//  Created by Geng on 2016/12/9.
//  Copyright © 2016年 Geng. All rights reserved.
//

#import "QQShareManager.h"
#import "WeakObject.h"

static NSString *const QQAppId = @"1105800529";


@interface QQShareManager ()
@property (nonatomic, strong) TencentOAuth *tencentOAuth;
@property (nonatomic, strong) NSMutableArray<WeakObject*> *listeners;
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
      _listeners = [NSMutableArray array];
   }
   return self;
}

#pragma mark - public fcuntion
- (void)addListener:(id<QQShareManagerDelegate>)listener
{
   WeakObject *wo = [[WeakObject alloc] init];
   wo.weakObject = listener;
   [self.listeners addObject:wo];
}

- (void)removeListener:(id<QQShareManagerDelegate>)listener
{
   WeakObject *wo = [[WeakObject alloc] init];
   wo.weakObject = listener;
   [self.listeners removeObject:wo];
}


- (BOOL)shareToQQWithTextMessage:(NSString *)text
{

   QQApiTextObject *txtObj = [QQApiTextObject objectWithText:text];
   SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:txtObj];
   QQApiSendResultCode sent = [QQApiInterface sendReq:req];
   [self delegateQQShareSendRequestResult:sent];
   return sent == EQQAPISENDSUCESS;
}

- (BOOL)shareToQQWithImageData:(NSData *)imageData
              preivewImageData:(NSData *)previewImageData
                         title:(NSString *)title
                   description:(NSString *)description
{
   QQApiImageObject *imageObj = [QQApiImageObject objectWithData:imageData previewImageData:previewImageData title:title description:description];
   SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:imageObj];
   QQApiSendResultCode sent = [QQApiInterface sendReq:req];
   [self delegateQQShareSendRequestResult:sent];
   return sent == EQQAPISENDSUCESS;
}

- (BOOL)shareToQQFavoritesWithImagesData:(NSArray<NSData *> *)imagesData
                        previewImageData:(NSData *)previewImageData
                                   title:(NSString *)title
                             description:(NSString *)description
{
   QQApiImageObject *imgObj = [QQApiImageObject objectWithData:previewImageData previewImageData:previewImageData title:title description:description imageDataArray:imagesData];
   [imgObj setCflag:kQQAPICtrlFlagQQShareFavorites];
   SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:imgObj];
   QQApiSendResultCode sent = [QQApiInterface sendReq:req];
   [self delegateQQShareSendRequestResult:sent];
   return sent == EQQAPISENDSUCESS;
}

- (BOOL)shareToQQWithFilePath:(NSString *)filePath
                     fileName:(NSString *)fileName
            preiviewImageData:(NSData *)imageData
                        title:(NSString *)title
                  description:(NSString *)description
{
   
   if ( [filePath hasSuffix:@".png"] ||
        [filePath hasSuffix:@".jpg"]) {
      NSData *fileData = [NSData dataWithContentsOfFile:filePath];
      QQApiImageObject *imgObjc = [QQApiImageObject objectWithData:fileData previewImageData:imageData title:title description:description];
      [imgObjc setCflag:kQQAPICtrlFlagQQShareDataline];
      SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:imgObjc];
      QQApiSendResultCode sent = [QQApiInterface sendReq:req];
      [self delegateQQShareSendRequestResult:sent];
      return sent == EQQAPISENDSUCESS;
   }else {
      NSData *fileData = [NSData dataWithContentsOfFile:filePath];
      QQApiFileObject *fileObj = [QQApiFileObject objectWithData:fileData previewImageData:imageData title:title description:description];
      fileObj.fileName = fileName;
      [fileObj setCflag:kQQAPICtrlFlagQQShareDataline];
      SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:fileObj];
      QQApiSendResultCode sent = [QQApiInterface sendReq:req];
      [self delegateQQShareSendRequestResult:sent];
      return sent == EQQAPISENDSUCESS;
   }
}

- (BOOL)shareMusicURL:(NSURL *)url
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
   [self delegateQQShareSendRequestResult:sent];
   return sent == EQQAPISENDSUCESS;
}

- (BOOL)shareVideoURL:(NSURL *)url
      previewImageURL:(NSURL *)imageURL
             flashURL:(NSURL *)flashURL
                title:(NSString *)title
          description:(NSString *)description
         toQQPlatform:(QQPlatform)platform
{
   QQApiVideoObject *videoObj = [QQApiVideoObject objectWithURL:url title:title description:description previewImageURL:imageURL];
   [videoObj setFlashURL:flashURL];
   SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:videoObj];
   QQApiSendResultCode sent;
   if (platform == QQPlatformQQ) {
      sent = [QQApiInterface sendReq:req];
   }
   else if (platform == QQPlatformQZone) {
      sent = [QQApiInterface SendReqToQZone:req];
   }
   [self delegateQQShareSendRequestResult:sent];
   return sent == EQQAPISENDSUCESS;
}

- (BOOL)shareURL:(NSURL *)url previewImageURL:(NSURL *)imageURL title:(NSString *)title description:(NSString *)description toQQPlatform:(QQPlatform)platform
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
   [self delegateQQShareSendRequestResult:sent];
   return sent == EQQAPISENDSUCESS;
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

#pragma mark - QQApiInterfaceDelegate
- (void)onResp:(QQBaseResp *)resp
{
   [self delegateQQShareShareResult:resp];
}

#pragma mark - TencentSessionDelegate
//分享到QZone回调
- (void)addShareResponse:(APIResponse*) response
{
   
}

- (void)responseDidReceived:(APIResponse*)response forMessage:(NSString *)message
{
   
}

#pragma mark - delegate convenience function
- (void)delegateQQShareSendRequestResult:(QQApiSendResultCode)sent
{
   QQShareManagerResult result = sent == 0 ? QQShareManagerResultSuccess : QQShareManagerResultFail;
   if (![QQApiInterface isQQInstalled]) {
      sent = EQQAPIQQNOTINSTALLED;
   }
   NSError *error = [self generateErrorWithQQApiSendResultCode:sent];
   for (WeakObject *wo in self.listeners) {
      id<QQShareManagerDelegate> listener = wo.weakObject;
      if ([listener respondsToSelector:@selector(onQQShareSendRequestResult:error:)]) {
         [listener onQQShareSendRequestResult:result error:error];
      }
   }
   
}

- (void)delegateQQShareShareResult:(QQBaseResp *)resp
{
   QQShareManagerResult result = [resp.result isEqualToString:@"0"]?QQShareManagerResultSuccess : QQShareManagerResultFail;
   NSError *error = [self generatErrorWithQQBaseResp:resp];
   for (WeakObject *wo in self.listeners) {
      id<QQShareManagerDelegate> listener = wo.weakObject;
      if ([listener respondsToSelector:@selector(onQQShareShareResult:error:)]) {
         [listener onQQShareShareResult:result error:error];
      }
   }
}

#pragma mark - private function
static NSString *const kSendResultErrorDomain = @"QQShareManager.sendRsultErrorDomain";
static NSString *const kQQBaseRespErrorDomain = @"QQShareManager.qqBaseRespErrorDomain";
- (NSError *)generateErrorWithQQApiSendResultCode:(QQApiSendResultCode)sent
{
   NSInteger errorCode = sent;
   NSString *errorDes;
   switch (sent) {
      case EQQAPISENDSUCESS:
         errorDes = @"SENDSUCESS";
         break;
      case EQQAPIQQNOTINSTALLED:
         errorDes = @"QQNOTINSTALLED";
         break;
      case EQQAPIQQNOTSUPPORTAPI:
         errorDes = @"QQNOTSUPPORTAPI";
         break;
      case EQQAPIMESSAGETYPEINVALID:
         errorDes = @"MESSAGETYPEINVALID";
         break;
      case EQQAPIMESSAGECONTENTNULL:
         errorDes = @"MESSAGECONTENTNULL";
         break;
      case EQQAPIMESSAGECONTENTINVALID:
         errorDes = @"MESSAGECONTENTINVALID";
         break;
      case EQQAPIAPPNOTREGISTED:
         errorDes = @"APPNOTREGISTED";
         break;
      case EQQAPIAPPSHAREASYNC:
         errorDes = @"APPSHAREASYNC";
         break;
      case EQQAPIQQNOTSUPPORTAPI_WITH_ERRORSHOW:
         errorDes = @"QQNOTSUPPORTAPI_WITH_ERRORSHOW";
         break;
      case EQQAPISENDFAILD:
         errorDes = @"SENDFAILD";
         break;
      case EQQAPIQZONENOTSUPPORTTEXT:
         errorDes = @"QZONENOTSUPPORTTEXT";
         break;
      case EQQAPIQZONENOTSUPPORTIMAGE:
         errorDes = @"QZONENOTSUPPORTIMAGE";
         break;
      case EQQAPIVERSIONNEEDUPDATE:
         errorDes = @"VERSIONNEEDUPDATE";
         break;
      default:
         break;
   }
   NSError *error = [NSError errorWithDomain:kSendResultErrorDomain code:errorCode userInfo:@{@"errorDescription":errorDes}];
   return error;
}

- (NSError *)generatErrorWithQQBaseResp:(QQBaseResp *)resp
{
   NSInteger errorcode = [resp.result integerValue];
   NSString *description = @"";
   if (resp.errorDescription) {
      description = resp.errorDescription;
   }
   
   NSError *error = [NSError errorWithDomain:kQQBaseRespErrorDomain code:errorcode userInfo:@{@"errorDescription":description}];
   return error;
}


@end
