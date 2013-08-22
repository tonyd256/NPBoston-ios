//
//  NPDateFormatter.h
//  NovProject
//
//  Created by Tony DiPasquale on 8/19/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

@interface NPDateFormatter : NSObject

@property (strong, nonatomic) NSDateFormatter *displayFormatter;
@property (strong, nonatomic) NSDateFormatter *serverFormatter;

+ (NPDateFormatter *)sharedFormatter;

@end
