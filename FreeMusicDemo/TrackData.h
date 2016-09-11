//
//  TrackData.h
//  
//
//  Created by 曾祺植 on 5/26/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TrackData : NSManagedObject

@property (nonatomic, retain) NSNumber * albumIdentifier;
@property (nonatomic, retain) NSString * albumName;
@property (nonatomic, retain) NSString * albumURL;
@property (nonatomic, retain) NSNumber * artistIdentifier;
@property (nonatomic, retain) NSString * artistImageURL;
@property (nonatomic, retain) NSString * artistName;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSString * logoImage;
@property (nonatomic, retain) NSNumber * trackIdentifier;
@property (nonatomic, retain) NSString * trackName;
@property (nonatomic, retain) NSString * trackURL;

@end
