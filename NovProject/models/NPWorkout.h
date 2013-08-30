//
//  NPWorkout.h
//  NPBoston
//
//  Created by Tony DiPasquale on 5/1/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

@class NPVerbal;
@class NPResult;

@interface NPWorkout : NSObject

@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *subtitle;
@property (strong, nonatomic) NSString *details;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSNumber *time;
@property (strong, nonatomic) NSNumber *amount;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSNumber *lat;
@property (strong, nonatomic) NSNumber *lng;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSNumber *verbalsCount;
@property (strong, nonatomic) NSNumber *resultsCount;
@property (strong, nonatomic) NPVerbal *verbal;
@property (strong, nonatomic) NPResult *result;

+ (NPWorkout *)workoutWithObject:(id)object;
- (id)initWithObject:(id)object;
- (NSString *)displayDate;

@end
