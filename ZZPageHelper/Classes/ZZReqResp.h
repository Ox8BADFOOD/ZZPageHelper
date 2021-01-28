//
//  ZZReqResp.h
//  InternetHospital
//
//  Created by Max on 2020/10/20.
//  Copyright © 2020 GaoLian. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZZReqResp : NSObject
@property(nonatomic,strong,nullable) NSArray *respArr;
@property(nonatomic,strong,nullable) NSError *error;
@property(nonatomic,assign) NSInteger nextIndex;
@property(nonatomic,assign) NSInteger maxIndex;
@property(nonatomic,assign) NSInteger maxCount;

//-(instancetype)initWithRespArr:( NSArray * _Nullable )arr err:(NSError *_Nullable)err maxIndex:(NSInteger)maxIndex maxCount:(NSInteger)maxCount nextIndex:(NSInteger)nextIndex NS_DESIGNATED_INITIALIZER;
-(instancetype)initWithRespArr:( NSArray * _Nullable )arr;
-(instancetype)initWithRespArr:( NSArray * _Nullable )arr  maxCount:(NSInteger)maxCount;
-(instancetype)initWithRespArr:( NSArray * _Nullable )arr  maxIndex:(NSInteger)maxIndex;
-(instancetype)initWithErr:(NSError *_Nullable)err;

+(instancetype)new NS_UNAVAILABLE;
-(instancetype)init;
@end

NS_ASSUME_NONNULL_END
