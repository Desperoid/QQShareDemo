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
static const NSUInteger fiveM = 1024*1024*5;

@interface QQShareManager ()
@property (nonatomic, strong) TencentOAuth *tencentOAuth;
@property (nonatomic, strong) NSMutableArray<WeakObject*> *listeners;
@end

@implementation QQShareManager

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

- (BOOL)isQQInstalled
{
   return [QQApiInterface isQQInstalled];
}

- (BOOL)isShareFileSizeLegal:(NSUInteger)fileSize
{
   return fileSize <= fiveM;
}

#pragma mark - QQ Share
- (BOOL)shareTextMessage:(NSString *)text toPlatform:(QQPlatform) platform
{
   if (![self checkIsQQInstalled]) {
      return NO;
   }
   if (platform == QQPlatformQQ) {
      QQApiTextObject *txtObj = [QQApiTextObject objectWithText:text];
      SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:txtObj];
      QQApiSendResultCode sent = [QQApiInterface sendReq:req];
      NSError *error = [self generateErrorWithQQApiSendResultCode:sent];
      QQShareManagerResult result = sent == EQQAPISENDSUCESS?QQShareManagerResultSuccess:QQShareManagerResultFail;
      [self delegateQQShareSendRequestResult:result error:error];
      return sent == EQQAPISENDSUCESS;
   }
   else if (platform == QQPlatformQZone) {
      QQApiImageArrayForQZoneObject *objc = [QQApiImageArrayForQZoneObject objectWithimageDataArray:nil title:text];
      SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:objc];
      QQApiSendResultCode sent = [QQApiInterface sendReq:req];
      NSError *error = [self generateErrorWithQQApiSendResultCode:sent];
      QQShareManagerResult result = sent == EQQAPISENDSUCESS?QQShareManagerResultSuccess:QQShareManagerResultFail;
      [self delegateQQShareSendRequestResult:result error:error];
      return sent == EQQAPISENDSUCESS;
   }
   return NO;
}

- (BOOL)shareImageDatas:(NSArray<NSData*>*)imagesData
               preivewImageData:(NSData *)previewImageData
                          title:(NSString *)title
                    description:(NSString *)description
                     toPlatform:(QQPlatform) platform;
{
   if (![self checkIsQQInstalled]) {
      return NO;
   }
   if (platform == QQPlatformQQ) {
      NSData *shareImageData = [imagesData firstObject];
      if (![self checkFileSize:shareImageData.length]) {
         return NO;
      }
      QQApiImageObject *imageObj = [QQApiImageObject objectWithData:shareImageData previewImageData:previewImageData title:title description:description imageDataArray:nil];
      SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:imageObj];
      QQApiSendResultCode sent = [QQApiInterface sendReq:req];
      NSError *error = [self generateErrorWithQQApiSendResultCode:sent];
      QQShareManagerResult result = sent == EQQAPISENDSUCESS?QQShareManagerResultSuccess:QQShareManagerResultFail;
      [self delegateQQShareSendRequestResult:result error:error];
      return sent == EQQAPISENDSUCESS;
   }
   else if (platform == QQPlatformQZone) {
      QQApiImageArrayForQZoneObject *obj = [QQApiImageArrayForQZoneObject objectWithimageDataArray:imagesData title:title];
      obj.description = description;
      SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:obj];
      QQApiSendResultCode sent = [QQApiInterface sendReq:req];
      NSError *error = [self generateErrorWithQQApiSendResultCode:sent];
      QQShareManagerResult result = sent == EQQAPISENDSUCESS?QQShareManagerResultSuccess:QQShareManagerResultFail;
      [self delegateQQShareSendRequestResult:result error:error];
      return sent == EQQAPISENDSUCESS;
   }
   return NO;
}

- (BOOL)shareToQQFavoritesWithImagesData:(NSArray<NSData *> *)imagesData
                        previewImageData:(NSData *)previewImageData
                                   title:(NSString *)title
                             description:(NSString *)description
{
   if (![self checkIsQQInstalled]) {
      return NO;
   }
   QQApiImageObject *imgObj = [QQApiImageObject objectWithData:previewImageData previewImageData:previewImageData title:title description:description imageDataArray:imagesData];
   [imgObj setCflag:kQQAPICtrlFlagQQShareFavorites];
   SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:imgObj];
   QQApiSendResultCode sent = [QQApiInterface sendReq:req];
   NSError *error = [self generateErrorWithQQApiSendResultCode:sent];
   QQShareManagerResult result = sent == EQQAPISENDSUCESS?QQShareManagerResultSuccess:QQShareManagerResultFail;
   [self delegateQQShareSendRequestResult:result error:error];
   return sent == EQQAPISENDSUCESS;
}

- (BOOL)shareToQQWithFilePath:(NSString *)filePath
                     fileName:(NSString *)fileName
            preiviewImageData:(NSData *)imageData
                        title:(NSString *)title
                  description:(NSString *)description
{
   if (![self checkIsQQInstalled]) {
      return NO;
   }
   NSData *fileData = [NSData dataWithContentsOfFile:filePath];
   if (![self checkFileSize:fileData.length]) {
      return NO;
   }
   if ( [self isImageFileName:filePath]) {
      QQApiImageObject *imgObjc = [QQApiImageObject objectWithData:fileData previewImageData:imageData title:title description:description];
      [imgObjc setCflag:kQQAPICtrlFlagQQShareDataline];
      SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:imgObjc];
      QQApiSendResultCode sent = [QQApiInterface sendReq:req];
      NSError *error = [self generateErrorWithQQApiSendResultCode:sent];
      QQShareManagerResult result = sent == EQQAPISENDSUCESS?QQShareManagerResultSuccess:QQShareManagerResultFail;
      [self delegateQQShareSendRequestResult:result error:error];
      return sent == EQQAPISENDSUCESS;
   }
   else {
      QQApiFileObject *fileObj = [QQApiFileObject objectWithData:fileData previewImageData:imageData title:title description:description];
      fileObj.fileName = fileName;
      [fileObj setCflag:kQQAPICtrlFlagQQShareDataline];
      SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:fileObj];
      QQApiSendResultCode sent = [QQApiInterface sendReq:req];
      NSError *error = [self generateErrorWithQQApiSendResultCode:sent];
      QQShareManagerResult result = sent == EQQAPISENDSUCESS?QQShareManagerResultSuccess:QQShareManagerResultFail;
      [self delegateQQShareSendRequestResult:result error:error];
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
   if (![self checkIsQQInstalled]) {
      return NO;
   }
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
   NSError *error = [self generateErrorWithQQApiSendResultCode:sent];
   QQShareManagerResult result = sent == EQQAPISENDSUCESS?QQShareManagerResultSuccess:QQShareManagerResultFail;
   [self delegateQQShareSendRequestResult:result error:error];
   return sent == EQQAPISENDSUCESS || sent == EQQAPIAPPSHAREASYNC; //分享网络图片URL的时候会出现 EQQAPIAPPSHAREASYNC
}

- (BOOL)shareVideoURL:(NSURL *)url
      previewImageURL:(NSURL *)imageURL
             flashURL:(NSURL *)flashURL
                title:(NSString *)title
          description:(NSString *)description
         toQQPlatform:(QQPlatform)platform
{
   if (![self checkIsQQInstalled]) {
      return NO;
   }
   /*
    * QQApiVideoObject类型的分享，目前在android和PC上接收消息时，展现有问题，待手Q版本以后更新支持
    * 目前如果要分享视频请使用 QQApiNewsObject 类型，URL填视频所在的H5地址
    
   QQApiVideoObject *videoObj = [QQApiVideoObject objectWithURL:flashURL title:title description:description previewImageURL:imageURL];
   [videoObj setFlashURL:flashURL];
    */
   QQApiNewsObject *videoObj = [QQApiNewsObject objectWithURL:url title:title description:description previewImageURL:imageURL];
   QQApiSendResultCode sent;
   if (platform == QQPlatformQQ) {
      SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:videoObj];
      sent = [QQApiInterface sendReq:req];
   }
   else if (platform == QQPlatformQZone) {
      SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:videoObj];
      sent = [QQApiInterface SendReqToQZone:req];
   }
   NSError *error = [self generateErrorWithQQApiSendResultCode:sent];
   QQShareManagerResult result = sent == EQQAPISENDSUCESS?QQShareManagerResultSuccess:QQShareManagerResultFail;
   [self delegateQQShareSendRequestResult:result error:error];
   return sent == EQQAPISENDSUCESS || sent == EQQAPIAPPSHAREASYNC;   //分享网络图片URL的时候会出现 EQQAPIAPPSHAREASYNC
}

- (BOOL)shareURL:(NSURL *)url localImageURL:(NSURL *)imageURL title:(NSString *)title description:(NSString *)description toQQPlatform:(QQPlatform)platform
{
   if (![self checkIsQQInstalled]) {
      return NO;
   }
   NSData *imageDate = [NSData dataWithContentsOfURL:imageURL];
   if (![self checkFileSize:imageDate.length]) {
      return NO;
   }
   QQApiNewsObject *newsObj = [QQApiNewsObject objectWithURL:url title:title description:description previewImageData:imageDate];
   SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
   QQApiSendResultCode sent;
   if (platform == QQPlatformQQ) {
      sent = [QQApiInterface sendReq:req];
   }
   else if (platform == QQPlatformQZone) {
      sent = [QQApiInterface SendReqToQZone:req];
   }
   NSError *error = [self generateErrorWithQQApiSendResultCode:sent];
   QQShareManagerResult result = sent == EQQAPISENDSUCESS?QQShareManagerResultSuccess:QQShareManagerResultFail;
   [self delegateQQShareSendRequestResult:result error:error];
   return sent == EQQAPISENDSUCESS;
}

- (BOOL)shareURL:(NSURL *)url networkImageURL:(NSURL *)imageURL title:(NSString *)title description:(NSString *)description toQQPlatform:(QQPlatform)platform
{
   if (![self checkIsQQInstalled]) {
      return NO;
   }
   QQApiNewsObject *newsObj = [QQApiNewsObject objectWithURL:url title:title description:description previewImageURL:imageURL];
   SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
   QQApiSendResultCode sent;
   if (platform == QQPlatformQQ) {
      sent = [QQApiInterface sendReq:req];
   }
   else if (platform == QQPlatformQZone) {
      sent = [QQApiInterface SendReqToQZone:req];
   }
   NSError *error = [self generateErrorWithQQApiSendResultCode:sent];
   QQShareManagerResult result = sent == EQQAPISENDSUCESS?QQShareManagerResultSuccess:QQShareManagerResultFail;
   [self delegateQQShareSendRequestResult:result error:error];
   return sent == EQQAPISENDSUCESS || sent == EQQAPIAPPSHAREASYNC; //分享网络图片URL的时候会出现 EQQAPIAPPSHAREASYNC
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
-(void)onReq:(QQBaseReq *)req
{
   
}

- (void)onResp:(QQBaseResp *)resp
{
   NSError *error = [self generatErrorWithQQBaseResp:resp];
   QQShareManagerResult result = [resp.result isEqualToString:@"0"]?QQShareManagerResultSuccess : QQShareManagerResultFail;
   [self delegateQQShareShareResult:result error:error];
}

- (void)isOnlineResponse:(NSDictionary *)response
{
   
}

#pragma mark - delegate convenience function
- (void)delegateQQShareSendRequestResult:(QQShareManagerResult)result error:(NSError *)error
{
   for (WeakObject *wo in self.listeners) {
      id<QQShareManagerDelegate> listener = wo.weakObject;
      if ([listener respondsToSelector:@selector(onQQShareSendRequestResult:error:)]) {
         [listener onQQShareSendRequestResult:result error:error];
      }
   }
   
}

- (void)delegateQQShareShareResult:(QQShareManagerResult)result error:(NSError *)error
{
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

/**
 检查是否安装手机qq,若未安装手机qq，则向delegate发送代理方法

 @return YES，已安装手机qq；NO，未安装手机qq
 */
- (BOOL)checkIsQQInstalled
{
   if(![self isQQInstalled]) {
      NSError *error = [self generateErrorWithQQApiSendResultCode:EQQAPIQQNOTINSTALLED];
      [self delegateQQShareSendRequestResult:QQShareManagerResultFail error:error];
      return NO;
   }
   return YES;
}


/**
 检查文件文件大小是否支持分享发送，最大文件为5m

 @param filesize 文件大小
 @return 文件大小是否支持分享发送
 */
- (BOOL)checkFileSize:(NSUInteger)filesize
{
   if(![self isShareFileSizeLegal:filesize]) {
      NSError *error = [NSError errorWithDomain:kSendResultErrorDomain code:EQQshareManagerTOOBIGDATASIZE userInfo:@{@"errorDescription":@"File size is too big"}];
      [self delegateQQShareSendRequestResult:QQShareManagerResultFail error:error];
      return NO;
   }
   return YES;
}


/**
 检查文件名后缀判断是否为图片

 @param fileName 文件名
 @return 是否为图片文件后缀
 */
- (BOOL)isImageFileName:(NSString *)fileName
{
   return [fileName hasSuffix:@".png"] ||
   [fileName hasSuffix:@".jpg"];
}

@end
