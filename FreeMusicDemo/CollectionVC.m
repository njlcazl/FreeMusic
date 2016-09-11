//
//  CollectionVC.m
//  FreeMusicDemo
//
//  Created by 曾祺植 on 5/26/15.
//  Copyright (c) 2015 曾祺植. All rights reserved.
//

#import "CollectionVC.h"
#import "CoreDataManager.h"
#import "PlayerVC.h"
#import "TrackNetItem.h"
#import "AppDelegate.h"
#import "TrackData.h"

@interface CollectionVC ()
@property (weak, nonatomic) IBOutlet UITableView *collectionTable;

@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) CoreDataManager *manager;

@end

@implementation CollectionVC

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    _dataArr = [[NSMutableArray alloc] init];
    _manager = [CoreDataManager sharedCoreDataManager];                    //设置manager
    self.collectionTable.dataSource = self;
    self.collectionTable.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];               //从Core Data中加载UITableView数据
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TrackData" inManagedObjectContext:_manager.managedObjContext];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"trackName" ascending:YES];
    NSArray *sortDescriptions = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptions];
    
    NSError *err = nil;
    NSArray *fetchResult = [_manager.managedObjContext executeFetchRequest:request error:&err];
    if (!fetchResult) {
        NSLog(@"error:%@, %@", err, [err userInfo]);
    }
    [self.dataArr removeAllObjects];
    [self.dataArr addObjectsFromArray:fetchResult];
    [self.collectionTable reloadData];
    
}

- (void)delItem:(TrackData *)item
{
    [[CoreDataManager sharedCoreDataManager].managedObjContext deleteObject:item];
    [self.dataArr removeObjectIdenticalTo:item];
    NSError *err = nil;
    
    BOOL isSaveSuccess = [[CoreDataManager sharedCoreDataManager].managedObjContext save:&err];          //保存数据
    if (!isSaveSuccess) {
        NSLog(@"Error: %@,%@",err, [err userInfo]);
    } else {
        NSLog(@"Del successful!");
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *strCell = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strCell];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:strCell];
    } 
    
    TrackData *item = [_dataArr objectAtIndex:indexPath.row];
    
    cell.textLabel.text = item.trackName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",item.artistName, item.albumName];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"FavoritePlayer" sender:indexPath];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"FavoritePlayer"] && [sender isKindOfClass:[NSIndexPath class]]) {
        PlayerVC *desVC = [segue destinationViewController];
        desVC.hidesBottomBarWhenPushed = YES;
        desVC.TrackQueue = self.dataArr;
        desVC.currentPath = sender;
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TRUE;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

/**
 *  设置滑动删除
 *
 *  @param tableView    tableView description
 *  @param editingStyle editingStyle description
 *  @param indexPath    indexPath description
 */

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        TrackData *item = self.dataArr[indexPath.row];
        [self delItem:item];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil]
                         withRowAnimation: UITableViewRowAnimationFade];
    }
}

@end












