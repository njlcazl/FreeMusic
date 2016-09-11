//
//  SearchVC.m
//  FreeMusicDemo
//
//  Created by 曾祺植 on 5/17/15.
//  Copyright (c) 2015 曾祺植. All rights reserved.
//


#import "SearchVC.h"
#import "ComUnit.h"
#import "TrackCell.h"
#import "ShowAlert.h"
#import "ActivityView.h"
#import "TrackNetItem.h"
#import "UITableView+Wave.h"
#import "MJRefresh.h"
#import "PlayerVC.h"

#define CellIdentifier @"CustomCell"
@interface SearchVC ()
@property (strong, nonatomic) IBOutlet UIView *SearchView;
@property (weak, nonatomic) IBOutlet UITableView *SearchTableView;
@property (weak, nonatomic) IBOutlet UITextField *SearchKey;
@end

@implementation SearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.SearchTableView.dataSource = self;
    [self.SearchTableView registerNib:[UINib nibWithNibName:@"TrackCell" bundle:nil]
               forCellReuseIdentifier:CellIdentifier];                                 //注册重用UITableViewCell类的xib文件，不能注册类，否则会导致无法重用
    [self setupRefresh];                                                               //加载上拉刷新视图
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;                              //隐藏导航栏
    [self.SearchTableView reloadData];                                                //刷新数据
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        self.dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    //    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.SearchTableView addFooterWithTarget:self action:@selector(footerRefreshing)];
    
    self.SearchTableView.footerPullToRefreshText = @"上拉可以加载更多数据了";
    self.SearchTableView.footerReleaseToRefreshText = @"松开马上加载更多数据了";
    self.SearchTableView.footerRefreshingText = @"正在加载数据中";
}

- (void)footerRefreshing
{
    [ComUnit searchKey:self.SearchKey.text page:self.currentPage callBack:^(NSArray *music, NSInteger *page, NSError *err) {    //刷新加载下一页数据
        if (err) {
            [ShowAlert showErr:@"Connect Error!"];
        }
        else
        {
            self.currentPage++;
            [self.dataSource addObjectsFromArray:music];
            [self.SearchTableView reloadData];
            [self.SearchTableView footerEndRefreshing];
        }
    }];
}


#pragma mark - Set Up the Quick Search

- (void)showAlert:(NSError *)err
{
    
}

- (IBAction)Search:(id)sender
{
    self.currentPage = 0;
    [ActivityView showActivity:self.SearchView];
    [ComUnit searchKey:self.SearchKey.text page:self.currentPage callBack:^(NSArray *music, NSInteger *page, NSError *err) {
        if (err) {
            [ShowAlert showErr:[err description]];
        }
        else
        {
            self.dataSource = [NSMutableArray arrayWithArray:music];
            self.currentPage++;
            [self.SearchTableView reloadDataAnimateWithWave:RightToLeftWaveAnimation];
            [ActivityView hidenActivity:self.SearchView];                                   //隐藏Activity视图
            [self.view endEditing:YES];
            if (self.SearchTableView.contentOffset.y > 0) {
                [self.SearchTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                            atScrollPosition:UITableViewScrollPositionTop
                                                    animated:YES];
            }               //点击搜索按钮后UITableView回滚到最上方
        } 
    }];
}


#pragma mark - TableView


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TrackCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    TrackNetItem *item = self.dataSource[indexPath.row];
    [cell setInfo:item row:indexPath.row callBack:^(NSString *TrackURL, NSString *AlbumURL) {        //要显示Cell时通信获取歌曲地址和专辑图片
        item.trackURL = TrackURL;
        item.albumURL = AlbumURL;
    }];
    [self.dataSource replaceObjectAtIndex:indexPath.row withObject:item];                           //更新item数据
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showPlayer" sender:indexPath];                                    //准备Segue，传入当前歌曲信息
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showPlayer"] && [sender isKindOfClass:[NSIndexPath class]]) {
        PlayerVC *desVC = [segue destinationViewController];
        desVC.hidesBottomBarWhenPushed = YES;            //自动隐藏底部导航栏
        desVC.TrackQueue = self.dataSource;
        desVC.currentPath = sender;
    }

}


@end


