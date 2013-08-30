#import "NPAnalytics.h"
#import "NSObject+MethodSwizzling.h"
#import "NPUser+Fixture.h"

SpecBegin(NPAnalytics)

describe(@"NPAnalytics", ^{
    __block OCMockObject *mixpanelMock;

    beforeEach(^{
        mixpanelMock = [OCMockObject niceMockForClass:[Mixpanel class]];
        [Mixpanel swizzleSingletonWithMockObject:mixpanelMock];
    });

    describe(@"analytics setup", ^{
        it(@"should setup mixpanel with phone properties", ^{
            [[mixpanelMock expect] registerSuperProperties:OCMOCK_ANY];
            [[NPAnalytics sharedAnalytics] setup];
            [mixpanelMock verify];
        });
    });

    describe(@"analytics user setting", ^{
        __block NPUser *user;

        beforeAll(^{
            user = [NPUser userWithObject:[NPUser jsonFixture]];
        });

        it(@"should set a user for mixpanel", ^{
            [[mixpanelMock expect] identify:user.objectId];
            [[NPAnalytics sharedAnalytics] setUser:user];
            [mixpanelMock verify];
        });
    });    

    describe(@"analytics event tracking", ^{
        it(@"should track an event with mixpanel", ^{
            [[mixpanelMock expect] track:@"TestEvent"];
            [[NPAnalytics sharedAnalytics] trackEvent:@"TestEvent"];
            [mixpanelMock verify];
        });

        it(@"should track an event with properties with mixpanel", ^{
            [[mixpanelMock expect] track:@"TestEvent" properties:@{@"test": @"testing"}];
            [[NPAnalytics sharedAnalytics] trackEvent:@"TestEvent" withProperties:@{@"test": @"testing"}];
            [mixpanelMock verify];
        });
    });
});

SpecEnd
