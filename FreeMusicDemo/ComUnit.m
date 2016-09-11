//
//  ComUnit.m
//  FreeMusicDemo
//
//  Created by 曾祺植 on 5/12/15.
//  Copyright (c) 2015 曾祺植. All rights reserved.
//

/**
 *
 * Get basic information about music
 * @param Searchkey
 * @param page
 @ @param callback
 *
 */



#import "ComUnit.h"
#import "TrackNetItem.h"

#define kFetchMusicURL @"http://music.163.com/api/search/get/web"
#define kFetchTrackAddress(TrackID) @"http://music.163.com/api/song/detail?ids=[%@]", TrackID
#define kFetchAlbumInfo(albumID) @"http://music.163.com/api/album/%@", albumID
#define kLimit 10
@implementation ComUnit


/**
 *  第一步:获取歌曲基本信息
 *
 *  @param key      搜索关键字
 *  @param page     页数
 *  @param callback 回调歌曲信息
 */
+ (void)searchKey:(NSString *)key page:(NSInteger *)page callBack:(ComUnitFetchMusicData)callback
{
    NSURL *url = [NSURL URLWithString:kFetchMusicURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"deflate,gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"http://music.163.com/" forHTTPHeaderField:@"Referer"];
    [request setValue:@"Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0)" forHTTPHeaderField:@"User-Agent"];
    NSString *body = [NSString stringWithFormat:@"s=%@&limit=%d&offset=%d&type=1",key,kLimit,(int)page * kLimit];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(connectionError) {
            callback(nil, page, connectionError);
        } else {
            NSMutableArray *musicArray = [NSMutableArray arrayWithCapacity:1];
            @try {
                NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                NSArray *tempArray = [[resultDic objectForKey:@"result"] objectForKey:@"songs"];
                [tempArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    TrackNetItem *item = [TrackNetItem initWithObj:obj];
                    [musicArray addObject:item];
                }];
            }
            @catch (NSException *exception) {
                connectionError = [NSError new];
            }
            @finally {
                callback(musicArray, page, nil);
            }
            
        }
    }];
}

/**
 *  获取歌曲网络地址和专辑图片地址
 *
 *  @param trackID  歌曲的编号
 *  @param callback 回调信息
 */

+ (void)FetchMusicURL:(NSString *)trackID callBack:(ComUnitFetchTrackAddress)callback
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kFetchTrackAddress(trackID)]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    [request setValue:@"deflate,gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"http://music.163.com/" forHTTPHeaderField:@"Referer"];
    [request setValue:@"Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0)" forHTTPHeaderField:@"User-Agent"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(connectionError) {
            callback(nil, nil, connectionError);
        } else {
            NSString *TrackURL = [[NSString alloc] init];
            NSString *AlbumURL = [[NSString alloc] init];
            @try {
                NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                NSDictionary *tempDic = [[resultDic valueForKey:@"songs"] firstObject];
                TrackURL = [tempDic valueForKey:@"mp3Url"];
                AlbumURL = [[tempDic valueForKey:@"album"] valueForKey:@"picUrl"];

            }
            @catch (NSException *exception) {
                connectionError = [NSError new];
            }
            @finally {
                callback(TrackURL, AlbumURL, nil);
            }
        }
        }];
}

/**
 *  同步获取歌曲地址和专辑图片地址
 *
 *  @param trackID  歌曲编号
 *  @param callback 回调信息
 */

+ (void)SyncFetchMusicURL:(NSString *)trackID callBack:(ComUnitFetchTrackAddress)callback
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kFetchTrackAddress(trackID)]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    [request setValue:@"deflate,gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"http://music.163.com/" forHTTPHeaderField:@"Referer"];
    [request setValue:@"Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0)" forHTTPHeaderField:@"User-Agent"];
    NSError *err =  [[NSError alloc] init];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&err];
    NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSDictionary *tempDic = [[resultDic valueForKey:@"songs"] firstObject];
    NSString *TrackURL = [tempDic valueForKey:@"mp3Url"];
    NSString *AlbumURL = [[tempDic valueForKey:@"album"] valueForKey:@"picUrl"];
    callback(TrackURL, AlbumURL, nil);
}

/**
 *  获取专辑列表
 *  @param albumID
 * @param callback 回调信息
 */
+ (void)FetchAlbumInfo:(NSString *)albumID callBack:(ComUnitFetchAlbumInfo)callback
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kFetchAlbumInfo(albumID)]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    [request setValue:@"deflate,gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"http://music.163.com/" forHTTPHeaderField:@"Referer"];
    [request setValue:@"Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0)" forHTTPHeaderField:@"User-Agent"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
     //   NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        
    }];
}

@end













