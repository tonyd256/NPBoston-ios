#import "NPAnalytics.h"
#import "NPUser+Fixture.h"

SPEC_BEGIN(NPAnalyticsSpec)

describe(@"NPAnalytics", ^{
    describe(@"analytics setup", ^{
        it(@"should setup mixpanel with phone properties", ^{
            [[[[Mixpanel sharedInstance] should] receive] registerSuperProperties:any()];
            [[NPAnalytics sharedAnalytics] setup];
        });
    });

    describe(@"analytics user setting", ^{
        __block NPUser *user;

        beforeAll(^{
            user = [NPUser userWithObject:[NPUser jsonFixture]];
        });

        it(@"should set a user for mixpanel", ^{
            [[[[Mixpanel sharedInstance] should] receive]identify:user.objectId];
            [[NPAnalytics sharedAnalytics] setUser:user];
        });
    });    

    describe(@"analytics event tracking", ^{
        it(@"should track an event with mixpanel", ^{
            [[[[Mixpanel sharedInstance] should] receive] track:@"TestEvent"];
            [[NPAnalytics sharedAnalytics] trackEvent:@"TestEvent"];
        });

        it(@"should track an event with properties with mixpanel", ^{
            [[[[Mixpanel sharedInstance] should] receive] track:@"TestEvent" properties:@{@"test": @"testing"}];
            [[NPAnalytics sharedAnalytics] trackEvent:@"TestEvent" withProperties:@{@"test": @"testing"}];
        });
    });
});

SPEC_END
