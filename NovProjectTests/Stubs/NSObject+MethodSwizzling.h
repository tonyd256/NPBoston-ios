//
//  NSObject+MethodSwizzling.h
//  NovProject
//
//  Created by Tony DiPasquale on 8/20/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

@interface NSObject (MethodSwizzling)

+ (void)swizzleMethod:(SEL)origMethod withMethod:(SEL)newMethod fromClass:(Class)newClass;
+ (void)unswizzleMethod:(SEL)origMethod withMethod:(SEL)newMethod fromClass:(Class)newClass;
+ (void)swizzleSingletonWithMockObject:(OCMockObject *)mockObject;

@end
