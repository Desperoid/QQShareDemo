//
//  WeakObject.m
//  QQshareDemo
//
//  Created by Geng on 2016/12/12.
//  Copyright © 2016年 Geng. All rights reserved.
//

#import "WeakObject.h"

@implementation WeakObject

- (BOOL)isEqual:(id)object
{
   if ([object isKindOfClass:[self class]]) {
      return [self.weakObject isEqual:((WeakObject*)object).weakObject];
   }
   return [super isEqual:object];
}

- (NSUInteger)hash
{
   return [self.weakObject hash];
}

@end
