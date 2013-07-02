//
//  NPAPIClient.h
//  NPBoston
//
//  Created by Tony DiPasquale on 4/28/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "AFHTTPClient.h"

@interface NPAPIClient : AFHTTPClient

+ (NPAPIClient *)sharedClient;

@end
