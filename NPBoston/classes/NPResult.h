//
//  NPResult.h
//  NPBoston
//
//  Created by Tony DiPasquale on 5/1/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NPResult : NSObject

@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) NSString *uid;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *wid;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSNumber *time;
@property (strong, nonatomic) NSNumber *amount;
@property (strong, nonatomic) NSString *pr;
@property (strong, nonatomic) NSString *comment;

+ (NPResult *)resultWithObject:(id)object;
- (NPResult *)initWithObject:(id)object;

+ (NSString *)timeToString:(NSNumber *)timeObj;
+ (NSNumber *)stringToTime:(NSString *)timeStr;

@end
