#import "NPCacheManager.h"
#import "NPAPIClient+StubExtentions.h"

SPEC_BEGIN(NPCacheManagerSpec)

describe(@"NPCacheManager", ^{
    describe(@"Workout Types cacheing", ^{
        __block id userDefaultsMock;
        __block id clientMock;
        __block NSArray *workoutTypesJSON;

        beforeAll(^{
            workoutTypesJSON = @[@{@"type": @"Stadium"},
                                 @{@"type": @"Hills"}];
        });

        beforeEach(^{
            userDefaultsMock = [NSUserDefaults mock];
            [NSUserDefaults stub:@selector(standardUserDefaults) andReturn:userDefaultsMock];

            clientMock = [NPAPIClient mock];
            [NPAPIClient stub:@selector(sharedClient) andReturn:clientMock];
        });

        it(@"should cache the workout types into the user defaults", ^{
            KWCaptureSpy *spy = [clientMock captureArgument:@selector(fetchWorkoutTypesWithSuccessBlock:) atIndex:0];
            [[[userDefaultsMock should] receive] setObject:workoutTypesJSON forKey:kWorkoutTypesCache];
            [[[userDefaultsMock should] receive] synchronize];
            [[NPCacheManager sharedManager] refreshWorkoutTypes];

            NPCollectionSuccessBlock block = spy.argument;
            block(workoutTypesJSON);
        });

        it(@"should retrieve the workout types from the user defaults", ^{
            [[userDefaultsMock stubAndReturn:workoutTypesJSON] objectForKey:kWorkoutTypesCache];
            [[[[NPCacheManager sharedManager] workoutTypes] should] equal:workoutTypesJSON];
        });
    });
});

SPEC_END
