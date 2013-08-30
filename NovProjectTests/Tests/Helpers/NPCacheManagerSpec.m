#import "NPCacheManager.h"
#import "NPAPIClient+StubExtentions.h"
#import "NSObject+MethodSwizzling.h"

SpecBegin(NPCacheManager)

describe(@"NPCacheManager", ^{    
    describe(@"Workout Types cacheing", ^{
        __block id userDefaults;
        __block OCMockObject *clientMock;
        __block NSArray *workoutTypesJSON;
        
        beforeAll(^{
            workoutTypesJSON = @[@{@"type": @"Stadium"},
                                 @{@"type": @"Hills"}];

            clientMock = [OCMockObject mockForClass:[NPAPIClient class]];
            [NPAPIClient swizzleSingletonWithMockObject:clientMock];
        });
        
        beforeEach(^{
            userDefaults = [OCMockObject niceMockForClass:[NSUserDefaults class]];
            [NPCacheManager sharedManager].userDefaults = userDefaults;

            [[[clientMock stub] andDo:^(NSInvocation *invocation) {
                void (^passedBlock)(NSArray *);
                [invocation getArgument:&passedBlock atIndex:2];
                passedBlock(workoutTypesJSON);
            }] fetchWorkoutTypesWithSuccessBlock:OCMOCK_ANY];
        });
        
        it(@"should cache the workout types into the user defaults", ^{
            [[userDefaults expect] setObject:workoutTypesJSON forKey:kWorkoutTypesCache];
            [[NPCacheManager sharedManager] refreshWorkoutTypes];
            [userDefaults verify];
        });
        
        it(@"should retreive the workout types from the user defaults", ^{
            [[[userDefaults stub] andReturn:workoutTypesJSON] objectForKey:kWorkoutTypesCache];
            expect([[NPCacheManager sharedManager] workoutTypes]).to.equal(workoutTypesJSON);
        });
    });
});

SpecEnd
