//
//  NSString+Extensions.h
//  NovProject
//
//  Created by Tony DiPasquale on 8/21/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

@interface NSString (Extensions)

- (BOOL)isEmpty;
- (NSString *)stringByStrippingWhitespace;
- (BOOL)containsString:(NSString *)string;

@end
