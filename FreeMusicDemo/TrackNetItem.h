//
//  TrackNetItem.h
//  FreeMusicDemo
//
//  Created by 曾祺植 on 5/12/15.
//  Copyright (c) 2015 曾祺植. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TrackData;

@interface TrackNetItem : NSObject
@property (nonatomic, strong) NSString *trackIdentifier;
@property (nonatomic, strong) NSString *albumIdentifier;
@property (nonatomic, strong) NSString *artistIdentifier;
@property (nonatomic, strong) NSString *logoImage;
@property (nonatomic, strong) NSString *trackName;
@property (nonatomic, strong) NSString *albumName;
@property (nonatomic, strong) NSString *artistName;
@property (nonatomic, strong) NSString *duration;
@property (nonatomic, strong) NSString *artistImageURL;
@property (nonatomic, strong) NSString *trackURL;
@property (nonatomic, strong) NSString *albumURL;
+ (id)initWithObj:(NSDictionary *)obj;
+ (id)initWithTrackData:(TrackData *)data;

@end
