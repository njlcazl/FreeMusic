//
//  SearchVC.h
//  FreeMusicDemo
//
//  Created by 曾祺植 on 5/17/15.
//  Copyright (c) 2015 曾祺植. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchVC : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic) NSInteger *currentPage;

- (NSMutableArray *)dataSource;

@end
