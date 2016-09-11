//
//  TrackNetItem.m
//  FreeMusicDemo
//
//  Created by 曾祺植 on 5/12/15.
//  Copyright (c) 2015 曾祺植. All rights reserved.
//

#import "TrackNetItem.h"
#import "TrackData.h"

@implementation TrackNetItem

/**
 *  解析json数据
 *
 *  @param obj json字典数据
 *
 *  @return 返回解析后数据
 */

+ (id)initWithObj:(NSDictionary *)obj
{
    TrackNetItem *item = [[TrackNetItem alloc] initWithObj:obj];
    return item;
}

- (id)initWithObj:(NSDictionary *)obj
{
    self = [super init];
    if (self) {
        self.trackIdentifier = [[obj valueForKey:@"id"] stringValue];
        self.albumIdentifier = [[obj valueForKey:@"album"] valueForKey:@"id"];
        self.artistIdentifier = [[obj valueForKey:@"artists"] valueForKey:@"id"];
        self.trackName = [obj valueForKey:@"name"];
        self.artistName = [[[obj valueForKey:@"artists"] valueForKey:@"name"] firstObject];
        self.albumName = [[obj valueForKey:@"album"] valueForKey:@"name"];
        self.duration = [obj valueForKey:@"duration"];
        self.artistImageURL = [[[obj valueForKey:@"artists"] valueForKey:@"img1v1Url"] firstObject];
    }
    return self;
}

+ (id)initWithTrackData:(TrackData *)data
{
    TrackNetItem *item = [[TrackNetItem alloc] initWithTrackData:data];
    return item;
}

- (id)initWithTrackData:(TrackData *)data
{
    self = [super init];
    if (self) {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        self.trackIdentifier = [numberFormatter stringFromNumber:data.trackIdentifier];
        self.albumIdentifier = [numberFormatter stringFromNumber:data.albumIdentifier];
     //   self.artistIdentifier = [numberFormatter stringFromNumber:data.artistIdentifier];
        self.duration = [numberFormatter stringFromNumber:data.duration];
        self.trackName = data.trackName;
        self.trackURL = data.trackURL;
        self.albumName = data.albumName;
        self.albumURL = data.albumURL;
        self.artistName = data.artistName;
        self.artistImageURL = data.artistImageURL;
        self.logoImage = data.logoImage;
    }
    return self;
}

/**
 *  便于NSLog输出调试
 *
 * 
 */
- (NSString *)description
{
    return [NSString stringWithFormat:@"trackIdentifier:%@,albumIdentifier%@,artistIdentifier:%@,trackName:%@,artistName:%@,albumName:%@,duration:%@,trackURL:%@,albumURL:%@", self.trackIdentifier, self.albumIdentifier, self.artistIdentifier, self.trackName, self.artistName, self.albumName, self.duration, self.trackURL, self.albumURL];
}

@end
