//
//  NPVerbal.h
//  NovProject
//
//  Created by Tony DiPasquale on 6/17/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

@interface NPVerbal : NSObject

@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) NSString *fid;
@property (strong, nonatomic) NSString *uid;
@property (strong, nonatomic) NSString *wid;
@property (strong, nonatomic) NSString *name;

+ (NPVerbal *)verbalWithObject:(id)object;
- (id)initWithObject:(id)object;

@end
