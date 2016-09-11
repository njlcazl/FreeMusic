//
//  ComUnit.h
//  FreeMusicDemo
//
//  Created by 曾祺植 on 5/12/15.
//  Copyright (c) 2015 曾祺植. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^ComUnitFetchMusicData)(NSArray *music,NSInteger *page, NSError *err);
typedef void(^ComUnitFetchTrackAddress)(NSString *TrackURL, NSString *AlbumURL, NSError *err);
typedef void(^ComUnitFetchAlbumInfo)(NSArray *albumInfo, NSError *err);


@interface ComUnit : NSObject

+ (void)searchKey:(NSString *)key page:(NSInteger *)page callBack:(ComUnitFetchMusicData)callback;
+ (void)FetchMusicURL:(NSString *)trackID callBack:(ComUnitFetchTrackAddress)callback;
+ (void)SyncFetchMusicURL:(NSString *)trackID callBack:(ComUnitFetchTrackAddress)callback;
+ (void)FetchAlbumInfo:(NSString *)albumID callBack:(ComUnitFetchAlbumInfo)callback;
@end