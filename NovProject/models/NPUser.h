//
//  NPUser.h
//  NovProject
//
//  Created by Tony DiPasquale on 6/12/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

@interface NPUser : NSObject

@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSString *fid;
@property (assign, nonatomic) BOOL admin;

+ (NPUser *)userWithObject:(id)object;
- (id)initWithObject:(id)object;

@end
