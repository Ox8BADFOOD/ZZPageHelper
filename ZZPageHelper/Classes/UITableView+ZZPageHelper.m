//
//  UITableView+ZZPageHelper.m
//  InternetHospital
//
//  Created by Max on 2020/10/20.
//  Copyright © 2020 GaoLian. All rights reserved.
//

#import "UITableView+ZZPageHelper.h"
#import <objc/runtime.h>
//#import <MJRefresh/MJRefresh.h>
#import "ZZWeakify.h"
#import "SVProgressHUD+Hisee.h"

static char kZZPageHelperOriginIndex;
static char kZZPageHelperCurrentIndex;
static char kZZMaxIndex;
static char kZZMaxDataSourceCount;
static char kZZPageFinishCountType;
static char kZZDataArr;
static char kZZReqResp;
static char kZZLoadingShow;
static char kZZLoadingDismiss;
static char kZZErrorShow;
static char kZZPostReq;
static char kRowInPage;

@implementation UITableView (ZZPageHelper)

-(instancetype)initPageHelperWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    if (self == [self initWithFrame:frame style:style]) {
        [self commonInit];
    }
    return self;
}
- (void)commonInit{
    self.originIndex = 1;
    self.currentIndex = self.originIndex;
    self.dataArr = [NSMutableArray array];
    self.maxDataSourceCount = NSIntegerMax;
    self.maxIndex = NSIntegerMax;
    self.finishCountType = ZZPageFinishCountTypeCount;
    self.rowInPage = 10;
    self.loadingShow = ^(){
        [SVProgressHUD gifLoading:HiseeLoading];
    };
    self.errorShow = ^(NSString * _Nonnull errDesc) {
        [SVProgressHUD danger:errDesc];
    };
    self.loadingDismiss = ^(){
        [SVProgressHUD dismiss];
    };
}

#pragma mark -- 刷新和加载
-(void)refresh{
    self.readyRefresh();
    self.loadingShow();
//    NSAssert([self postReq], @"确认不发请求吗？不发送请求应该用不到分页");
    if (self.postReq) {
        self.postReq(self.currentIndex);
    }
}

-(void)loading{
    self.readyLoading();
    self.loadingShow();
    if (self.postReq) {
        self.postReq(self.currentIndex);
    }
}

#pragma mark -- ready 加载前的准备
-(ZZPageHelperReadyRefresh)readyRefresh{
    ZZPageHelperReadyRefresh ready = ^(){
        [self.mj_footer endRefreshing];
        self.currentIndex = self.originIndex;
    };
    return ready;
}

-(ZZPageHelperReadyRefresh)readyLoading{
    ZZPageHelperReadyRefresh ready = ^(){
        [self.mj_header endRefreshing];
        self.currentIndex = self.currentIndex + 1;
    };
    return ready;
}

#pragma mark -- pageLoadSuccess/Failure 请求成功的处理
-(ZZPageHelperReqSuccess)pageLoadSuccess{
    @weakify(self);
    ZZPageHelperReqSuccess success = ^(){
        @strongify(self);
        [self bothEndRefreshing];
        
        //处理数据源
        if (self.currentIndex == self.originIndex) {
            self.dataArr = self.reqResp.respArr.mutableCopy;
        }else{
            if(self.reqResp.respArr.count){
                [self.dataArr addObjectsFromArray:self.reqResp.respArr];
            }
        }
        
        //处理刷到底的情况
        self.maxIndex           = self.reqResp.maxIndex;
        self.maxDataSourceCount = self.reqResp.maxCount;
        
        if (self.finishCountType == ZZPageFinishCountTypeCount) {
            if (self.dataArr.count >= self.maxDataSourceCount) {
                [self.mj_footer endRefreshingWithNoMoreData];
            }
        }else if(self.finishCountType == ZZPageFinishCountTypeIndex){
            if (self.currentIndex >= self.maxIndex) {
                [self.mj_footer endRefreshingWithNoMoreData];
            }
        }else if (self.finishCountType == ZZPageFinishCountTypeCuriosity){
            if(self.reqResp.respArr.count < self.rowInPage){
                [self.mj_footer endRefreshingWithNoMoreData];
            }
        }else{
            NSAssert(0, @"no implement method");
        }
        //更新到UI
        [self reloadData];
    };
    return success;
}

-(ZZPageHelperReqFailure)pageLoadFailure{
    ZZPageHelperReqFailure failure = ^(){
        [self bothEndRefreshing];
        self.currentIndex = self.currentIndex - 1;
        if (self.reqResp.error) {
            self.errorShow(self.reqResp.error.domain);
        }
    };
    return failure;
}

-(UITableView *)setupMJHead{
    self.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self refresh];
    }];
    self.dataArr = [NSMutableArray array];
    return self;
}

-(UITableView *)setupMJFooter{
    self.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self loading];
    }];
    self.dataArr = [NSMutableArray array];
    return self;
}
#pragma mark -- postReq 发送网络请求
-(void)setPostReq:(void (^)(NSInteger))postReq{
    objc_setAssociatedObject(self, &kZZPostReq, postReq, OBJC_ASSOCIATION_COPY);
}
-(void (^)(NSInteger))postReq{
    return objc_getAssociatedObject(self, &kZZPostReq);
}

#pragma mark -- originIndex 原始页面下标
-(void)setOriginIndex:(NSInteger)originIndex{
    objc_setAssociatedObject(self, &kZZPageHelperOriginIndex, @(originIndex), OBJC_ASSOCIATION_ASSIGN);
}
-(NSInteger)originIndex{
    
    return [objc_getAssociatedObject(self, &kZZPageHelperOriginIndex) integerValue];
}

#pragma mark -- currentIndex 当前页面下标
-(void)setCurrentIndex:(NSInteger)currentIndex{
    objc_setAssociatedObject(self, &kZZPageHelperCurrentIndex, @(currentIndex), OBJC_ASSOCIATION_ASSIGN);
}
-(NSInteger)currentIndex{
    return [objc_getAssociatedObject(self, &kZZPageHelperCurrentIndex) integerValue];
}

#pragma mark -- maxIndex 最大页面下标
-(void)setMaxIndex:(NSInteger)maxIndex{
    objc_setAssociatedObject(self, &kZZMaxIndex, @(maxIndex), OBJC_ASSOCIATION_ASSIGN);
}
-(NSInteger)maxIndex{
    return [objc_getAssociatedObject(self, &kZZMaxIndex) integerValue];
}

#pragma mark -- maxDataSourceCount 最大模型个数
-(void)setMaxDataSourceCount:(NSInteger)maxDataSourceCount{
    objc_setAssociatedObject(self, &kZZMaxDataSourceCount, @(maxDataSourceCount), OBJC_ASSOCIATION_ASSIGN);
}
-(NSInteger)maxDataSourceCount{
    return [objc_getAssociatedObject(self, &kZZMaxDataSourceCount) integerValue];
}

#pragma mark -- finishCountType 判断加载完成的类型
-(void)setFinishCountType:(ZZPageFinishCountType)finishCountType{
    objc_setAssociatedObject(self, &kZZPageFinishCountType, @(finishCountType), OBJC_ASSOCIATION_ASSIGN);
}
-(ZZPageFinishCountType)finishCountType{
    return [objc_getAssociatedObject(self, &kZZPageFinishCountType) integerValue];
}

#pragma mark -- maxDataSourceCount 分页中一页请求多少数据
-(void)setRowInPage:(NSInteger)rowInPage{
    objc_setAssociatedObject(self, &kRowInPage, @(rowInPage), OBJC_ASSOCIATION_ASSIGN);
}
-(NSInteger)rowInPage{
    return [objc_getAssociatedObject(self, &kRowInPage) integerValue];
}

#pragma mark -- dataArr 数据源
-(void)setDataArr:(NSMutableArray *)dataArr{
    self.mj_footer.hidden = !dataArr.count;
    objc_setAssociatedObject(self, &kZZDataArr, dataArr, OBJC_ASSOCIATION_RETAIN);
}
-(NSMutableArray *)dataArr{
    return objc_getAssociatedObject(self, &kZZDataArr);
}

#pragma mark -- reqResp 请求响应
-(void)setReqResp:(ZZReqResp *)reqResp{
    objc_setAssociatedObject(self, &kZZReqResp, reqResp, OBJC_ASSOCIATION_RETAIN);
    self.loadingDismiss();
    if (reqResp.error || !self.reqResp.respArr) {//|| self.reqResp.respArr.count == 0
        self.pageLoadFailure();
        return;
    }
    self.pageLoadSuccess();
}
-(ZZReqResp *)reqResp{
    return objc_getAssociatedObject(self, &kZZReqResp);
}

#pragma mark -- loadingShow/Dismiss 菊花出现/消失
-(void)setLoadingShow:(void (^)(void))loadingShow{
    objc_setAssociatedObject(self, &kZZLoadingShow, loadingShow, OBJC_ASSOCIATION_COPY);
}
-(void)setLoadingDismiss:(void (^)(void))loadingDismiss{
    objc_setAssociatedObject(self, &kZZLoadingDismiss, loadingDismiss, OBJC_ASSOCIATION_COPY);
}

-(void)setErrorShow:(void (^)(NSString * _Nonnull))errorShow{
    objc_setAssociatedObject(self, &kZZErrorShow, errorShow, OBJC_ASSOCIATION_COPY);
}

-(void (^)(void))loadingShow{
    return objc_getAssociatedObject(self, &kZZLoadingShow);
}
-(void (^)(void))loadingDismiss{
    return objc_getAssociatedObject(self, &kZZLoadingDismiss);
}
-(void (^)(NSString * _Nonnull))errorShow{
    return objc_getAssociatedObject(self, &kZZErrorShow);
}

-(void)bothEndRefreshing{
    [self.mj_header endRefreshing];
    [self.mj_footer endRefreshing];
}

@end
