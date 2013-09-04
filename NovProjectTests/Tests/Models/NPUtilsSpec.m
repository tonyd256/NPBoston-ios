#import "NPUtils.h"

SPEC_BEGIN(NPUtilsSpec)

describe(@"NPUtils helper", ^{
    __block NSNumber *timeNumber;
    __block NSString *timeString;
    
    beforeAll(^{
        timeNumber = @5000;
        timeString = @"01:23:20";
    });
    
    it(@"should convert time number to string", ^{
        NSString *str = [NPUtils timeToString:timeNumber];
        [[str should] equal:timeString];
    });
    
    it(@"should convert time string to number", ^{
        NSNumber *num = [NPUtils stringToTime:timeString];
        [[num should] equal:timeNumber];
    });
});

SPEC_END
