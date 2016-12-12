//
//  WeakObject.h
//  QQshareDemo
//
//  Created by Geng on 2016/12/12.
//  Copyright © 2016年 Geng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeakObject : NSObject
@property (nonatomic, unsafe_unretained) id weakObject;
@end
