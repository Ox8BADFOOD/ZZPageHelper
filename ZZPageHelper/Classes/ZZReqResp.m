//
//  ZZReqResp.m
//  InternetHospital
//
//  Created by Max on 2020/10/20.
//  Copyright © 2020 GaoLian. All rights reserved.
//

#import "ZZReqResp.h"

@implementation ZZReqResp
 -(instancetype)initWithRespArr:( NSArray * _Nullable )arr err:(NSError *_Nullable)err maxIndex:(NSInteger)maxIndex maxCount:(NSInteger)maxCount nextIndex:(NSInteger)nextIndex {
     if (self == [super init]) {
         self.respArr = arr;
         self.error = err;
         self.maxIndex = maxIndex;
         self.maxCount = maxCount;
         self.nextIndex = nextIndex;
     }
     return self;
 };

-(instancetype)initWithRespArr:( NSArray * _Nullable )arr  maxCount:(NSInteger)maxCount{
    return [self initWithRespArr:arr err:nil maxIndex:0 maxCount:maxCount nextIndex:0];
}

-(instancetype)initWithRespArr:( NSArray * _Nullable )arr  maxIndex:(NSInteger)maxIndex{
    return [self initWithRespArr:arr err:nil maxIndex:maxIndex maxCount:NSIntegerMax nextIndex:0];
}

-(instancetype)initWithRespArr:( NSArray * _Nullable )arr{
    return [self initWithRespArr:arr err:nil maxIndex:NSIntegerMax maxCount:NSIntegerMax nextIndex:0];
}

-(instancetype)initWithErr:(NSError *_Nullable)err{
    return [self initWithRespArr:nil err:err maxIndex:0 maxCount:NSIntegerMax nextIndex:0];
}

-(instancetype)init{
    return [self initWithRespArr:nil err:nil maxIndex:0 maxCount:0 nextIndex:0];
}
@end
