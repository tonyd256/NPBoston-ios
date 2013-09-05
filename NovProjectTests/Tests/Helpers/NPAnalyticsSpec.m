#import "NPAnalytics.h"
#import "Mixpanel.h"
#import "NPUser+Fixture.h"

SPEC_BEGIN(NPAnalyticsSpec)

describe(@"NPAnalytics", ^{
    describe(@"analytics setup", ^{
        it(@"should setup mixpanel with phone properties", ^{
            [[[[Mixpanel sharedInstance] should] receive] registerSuperProperties:any()];
            [NPAnalytics setup];
        });
    });

    describe(@"analytics user setting", ^{
        __block NPUser *user;

        beforeAll(^{
            user = [NPUser userWithObject:[NPUser jsonFixture]];
        });

        it(@"should set a user for mixpanel", ^{
            [[[[Mixpanel sharedInstance] should] receive]identify:user.objectId];
            [NPAnalytics setUser:user];
        });
    });    

    describe(@"analytics event tracking", ^{
        it(@"should track an event with mixpanel", ^{
            [[[[Mixpanel sharedInstance] should] receive] track:@"TestEvent"];
            [NPAnalytics track:@"TestEvent"];
        });

        it(@"should track an event with properties with mixpanel", ^{
            [[[[Mixpanel sharedInstance] should] receive] track:@"TestEvent" properties:@{@"test": @"testing"}];
            [NPAnalytics track:@"TestEvent" properties:@{@"test": @"testing"}];
        });
    });
});

SPEC_END
