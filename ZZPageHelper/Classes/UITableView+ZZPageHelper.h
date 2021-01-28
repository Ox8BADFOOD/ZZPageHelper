//
//  UITableView+ZZPageHelper.h
//  InternetHospital
//
//  Created by Max on 2020/10/20.
//  Copyright © 2020 GaoLian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MJRefresh/MJRefresh.h>
#import "ZZReqResp.h"
#import <SVProgressHUD/SVProgressHUD.h>
NS_ASSUME_NONNULL_BEGIN
//准备下啦/上啦刷新的UI准备
//下拉刷新叫做refresh
//上拉加载更多叫做loading
typedef void(^ZZPageHelperReadyRefresh)(void);
typedef void(^ZZPageHelperReadyLoading)(void);
//请求成功后关于页码的操作
typedef void(^ZZPageHelperReqSuccess)(void);
//请求失败后关于页码的操作
typedef void(^ZZPageHelperReqFailure)(void);

typedef NS_ENUM(NSUInteger, ZZPageFinishCountType) {
    //maxDataSourceCount来判断是否加载完整
    ZZPageFinishCountTypeCount,
    //maxIndex来判断是否加载完整
    ZZPageFinishCountTypeIndex,
    //没有给任何分页相关的数据，自己根据数组长度判断（奇葩）
    ZZPageFinishCountTypeCuriosity,
};

@interface UITableView(ZZPageHelper)

@property(nonatomic,assign) NSInteger originIndex;
@property(nonatomic,assign) NSInteger currentIndex;
//分页中一页请求多少数据
@property(nonatomic,assign) NSInteger rowInPage;
//数据源
@property(nonatomic,strong) NSMutableArray * dataArr;
//加载完成根据maxDataSourceCount/maxIndex判断
@property(nonatomic,assign) ZZPageFinishCountType finishCountType;

//最大的数据源个数
@property(nonatomic,assign) NSInteger maxDataSourceCount;
//最大的分页数
@property(nonatomic,assign) NSInteger maxIndex;

//UI的处理
@property(nonatomic,copy,readonly) ZZPageHelperReadyRefresh readyRefresh;
@property(nonatomic,copy,readonly) ZZPageHelperReadyLoading readyLoading;
//网络请求个体差异大，交友外面的部分实现
//要处理页码逻辑=，必须自己实现网络请求的回调（至少是一部分），
@property(nonatomic,copy,readonly) ZZPageHelperReqSuccess pageLoadSuccess;
@property(nonatomic,copy,readonly) ZZPageHelperReqFailure pageLoadFailure;

@property(nonatomic,copy,readwrite) void(^loadingShow)(void);
@property(nonatomic,copy,readwrite) void(^loadingDismiss)(void);
@property(nonatomic,copy,readwrite) void(^errorShow)(NSString *errDesc);

//请求的相应
@property(nonatomic,strong) ZZReqResp *reqResp;
//外部实现的网络请求
@property(nonatomic,copy) void(^postReq)(NSInteger index);

- (void)commonInit;
-(UITableView *)setupMJHead;
-(UITableView *)setupMJFooter;
//加载
-(void)loading;
//刷新
-(void)refresh;

-(instancetype)initPageHelperWithFrame:(CGRect)frame style:(UITableViewStyle)style;
@end



NS_ASSUME_NONNULL_END
