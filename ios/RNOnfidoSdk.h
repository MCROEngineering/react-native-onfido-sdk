#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RNOnfidoSdk: NSObject<RCTBridgeModule>

+ (void)startSDKWithToken:(NSString *)token applicantId:(NSString *)applicantId countryCode:(NSString *)countryCode documentType:(int)documentType successCallback:(RCTResponseSenderBlock)successCallback errorCallback:(RCTResponseErrorBlock)errorCallback;

- (void)run;

@end
