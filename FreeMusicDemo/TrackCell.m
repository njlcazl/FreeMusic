//
//  TrackCell.m
//  FreeMusicDemo
//
//  Created by 曾祺植 on 5/23/15.
//  Copyright (c) 2015 曾祺植. All rights reserved.
//

#import "TrackCell.h"
#import "TrackData.h"
#import "SearchVC.h"
#import "ComUnit.h"
#import "TrackNetItem.h"
#import "CoreDataManager.h"
#import "UIImageView+WebCache.h"

@interface TrackCell()

@property (weak, nonatomic) IBOutlet UILabel *TrackName;
@property (weak, nonatomic) IBOutlet UILabel *ArtistName;
@property (weak, nonatomic) IBOutlet UIImageView *ImageView;
@property (nonatomic, strong) CoreDataManager *manager;
@property (nonatomic,strong) NSOperationQueue *queue;
@property (weak, nonatomic) IBOutlet UIButton *CollectionBtn;
@end

@implementation TrackCell

- (void)awakeFromNib
{
    _manager = [CoreDataManager sharedCoreDataManager];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.selectionStyle = UITableViewCellAccessoryNone;                     //去除点击时的阴影效果
    // Configure the view for the selected state
}

- (IBAction)Collect:(UIButton *)sender
{
    [self.CollectionBtn setImage:[UIImage imageNamed:@"heart.png"] forState:UIControlStateNormal];
    [self ConfigureData];
    [self.CollectionBtn setEnabled:NO];
}


/**
 *  查询当前歌曲是否已经收藏过
 *
 *  @return BOOL
 */
- (BOOL)isExist
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TrackData"];
    request.predicate = [NSPredicate predicateWithFormat:@"trackIdentifier = %@", self.currentTrack.trackIdentifier];
    
    NSError *err;
    NSArray *matchs = [_manager.managedObjContext executeFetchRequest:request error:&err];
    if (matchs.count > 0)return YES;
    else return NO;
}

- (void)ConfigureData
{
    
    self.data = [NSEntityDescription insertNewObjectForEntityForName:@"TrackData"
                                              inManagedObjectContext:[CoreDataManager sharedCoreDataManager].managedObjContext];
    [self.data setTrackIdentifier:[NSNumber numberWithInteger:[self.currentTrack.trackIdentifier intValue]]];
    [self.data setTrackName:self.currentTrack.trackName];
    [self.data setTrackURL:self.currentTrack.trackURL];
    [self.data setAlbumIdentifier:[NSNumber numberWithInteger:[self.currentTrack.albumIdentifier intValue]]];
    [self.data setAlbumName:self.currentTrack.albumName];
    [self.data setAlbumURL:self.currentTrack.albumURL];
//    [self.data setArtistIdentifier:[NSNumber numberWithInteger:[self.currentTrack.artistIdentifier intValue]]];
    [self.data setArtistImageURL:self.currentTrack.artistImageURL];
    [self.data setArtistName:self.currentTrack.artistName];
    [self.data setDuration:[NSNumber numberWithInteger:[self.currentTrack.duration intValue]]];
    NSError *err = nil;
    BOOL isSaveSuccess = [[CoreDataManager sharedCoreDataManager].managedObjContext save:&err];
    if (!isSaveSuccess) { 
        
    }else
    {
        NSLog(@"Save successFull");
    }
}

- (void)setInfo:(TrackNetItem *)item row:(NSInteger)row callBack:(FetchTrackAddress)callback
{
    self.currentTrack = item;
    [self.TrackName setText:item.trackName];
    [self.ArtistName setText:item.artistName];
    self.CollectionBtn.adjustsImageWhenHighlighted = NO;
    if ([self isExist]) {                                                    //通过用户的收藏情况设置红心图片
        [self.CollectionBtn setImage:[UIImage imageNamed:@"heart.png"] forState:UIControlStateNormal];
        [self.CollectionBtn setEnabled:NO];
    } else {
        [self.CollectionBtn setImage:[UIImage imageNamed:@"white_heart.png"] forState:UIControlStateNormal];
        [self.CollectionBtn setEnabled:YES];
    }
    
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
    }
    [_queue cancelAllOperations];                         //取消所有线程操作，获取当前需要展示的信息
    [_queue addOperationWithBlock:^{
        [ComUnit FetchMusicURL:item.trackIdentifier callBack:^(NSString *TrackURL, NSString *AlbumURL, NSError *err) {
            item.trackURL = TrackURL;
            item.albumURL = AlbumURL;
            [self.ImageView sd_setImageWithURL:[NSURL URLWithString:item.albumURL]
                              placeholderImage:[UIImage imageNamed:@"scene.jpg"]];
            callback(item.trackURL, item.albumURL);
        }];
    }];
}

@end
