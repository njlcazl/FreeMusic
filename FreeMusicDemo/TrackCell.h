//
//  TrackCell.h
//  FreeMusicDemo
//
//  Created by 曾祺植 on 5/23/15.
//  Copyright (c) 2015 曾祺植. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^FetchTrackAddress)(NSString *TrackURL, NSString *AlbumURL);
@class TrackNetItem;
@class TrackData;

@interface TrackCell : UITableViewCell
@property (nonatomic, strong) TrackNetItem *currentTrack;
@property (nonatomic, strong) TrackData *data;

- (void)setInfo:(TrackNetItem *)item row:(NSInteger)row callBack:(FetchTrackAddress)callback;

@end
