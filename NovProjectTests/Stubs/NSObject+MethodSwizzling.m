//
//  NSObject+MethodSwizzling.m
//  NovProject
//
//  Created by Tony DiPasquale on 8/20/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import "NSObject+MethodSwizzling.h"
#import <objc/runtime.h>

@implementation NSObject (MethodSwizzling)

static OCMockObject *_returnMock;
static Method exchangedMethod;

+ (OCMockObject *)returnMockObject
{
    return _returnMock;
}

+ (void)swizzleMethod:(SEL)origMethod withMethod:(SEL)newMethod fromClass:(Class)newClass
{
    Method originalMethod = class_getClassMethod([self class], origMethod);
    Method mockMethod = class_getClassMethod(newClass, newMethod);
    method_exchangeImplementations(originalMethod, mockMethod);
}

+ (void)unswizzleMethod:(SEL)origMethod withMethod:(SEL)newMethod fromClass:(Class)newClass
{
    Method originalMethod = class_getClassMethod([self class], origMethod);
    Method mockMethod = class_getClassMethod(newClass, newMethod);
    method_exchangeImplementations(mockMethod, originalMethod);
}

+ (void)swizzleSingletonWithMockObject:(OCMockObject *)mockObject
{
    if (_returnMock) {
        // unswizzle first if mock exists meaning it had been swizzled before
        Method mockMethod = class_getClassMethod([self class], @selector(returnMockObject));
        method_exchangeImplementations(mockMethod, exchangedMethod);
    }
    
    _returnMock = mockObject;
    
    unsigned count = 0;
    Method *methods = class_copyMethodList(object_getClass(self), &count);

    for (int i = 0; i < count; i++) {
        NSString *name = @(sel_getName(method_getName(methods[i])));
        if ([name hasPrefix:@"shared"] && method_getNumberOfArguments(methods[i]) == 2) {
            Method mockMethod = class_getClassMethod([self class], @selector(returnMockObject));
            method_exchangeImplementations(methods[i], mockMethod);
            exchangedMethod = methods[i];
            break;
        }
    }
}

@end
