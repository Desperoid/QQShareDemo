//
//  QQShareManager.h
//  QQshareDemo
//
//  Created by Geng on 2016/12/9.
//  Copyright © 2016年 Geng. All rights reserved.
//
//  QQ分享模块

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>

typedef NS_ENUM(NSUInteger, QQPlatform) {
   QQPlatformQQ,
   QQPlatformQZone
};

@interface QQShareManager : NSObject <TencentSessionDelegate>

/**
 获取QQShareManager单例

 @return QQShareManager单例
 */
+ (instancetype)shareInstance;

/**
 分享纯文字到qq

 @param text 分享文字内容
 */
- (void)shareToQQWithTextMessage:(NSString *)text;

/**
 分享纯图片到qq

 @param imageData 分享图片data
 @param previewImageData 分享预览图片data
 @param title 分享标题
 @param description 分享描述
 */
- (void)shareToQQWithImageData:(NSData *)imageData
              preivewImageData:(NSData *)previewImageData
                         title:(NSString *)title
                   description:(NSString *)description;

/**
 分享多张图片到QQ收藏

 @param imagesData 包含分享图片data的数组
 @param previewImageData 分享预览图片data
 @param title 分享标题
 @param description 分享描述
 */
- (void)shareToQQFavoritesWithImagesData:(NSArray<NSData*>*)imagesData
                        previewImageData:(NSData *)previewImageData
                                   title:(NSString *)title
                             description:(NSString *)description;

/**
 分享新闻（分享url链接）

 @param url 点击跳转URL
 @param imageURL 分享预览图片URL
 @param title 主题
 @param description 描述
 @param platform 平台，QQ或QZONE
 */
- (void)shareURL:(NSURL *)url
 previewImageURL:(NSURL *)imageURL
           title:(NSString *)title
     description:(NSString *)description
    toQQPlatform:(QQPlatform)platform;


/**
 分享音乐

 @param url  分享跳转URL
 @param imageURL 分享预览图片URL
 @param flashURL 音乐播放流媒体地址
 @param title 分享标题
 @param description 分享描述
 @param platform 平台，QQ或QZONE
 */
- (void)shareMusicURL:(NSURL *)url
      preivewImageURL:(NSURL *)imageURL
             flashURL:(NSURL *)flashURL
                title:(NSString *)title
          description:(NSString *)description
         toQQPlatform:(QQPlatform)platform;


/**
 分享文件（仅数据线）

 @param filePath 分享文件路径
 @param fileName 分享文件名
 @param imageData 分享预览图
 @param title 分享标题
 @param description 分享描述
 */
- (void)shareToQQWithFilePath:(NSString *)filePath
                     fileName:(NSString *)fileName
            preiviewImageData:(NSData *)imageData
                        title:(NSString *)title
                  description:(NSString *)description;

@end
