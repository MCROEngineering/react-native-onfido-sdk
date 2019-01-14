//
//  RCTConvert+FlowConfiguration.m
//  RNOnfidoSdk
//
//  Created by Mihai Chifor on 13/12/2018.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "ONFlowConfigBuilder+FlowConfiguration.h"

@implementation ONFlowConfigBuilder (FlowConfiguration)

+ (NSError *)validateParams:(id)params {
    NSDictionary *dictionary = [RCTConvert NSDictionary:params];
    NSString *token = dictionary[@"token"];
    NSString *applicantId = dictionary[@"applicantId"];
    id documentTypes = dictionary[@"documentTypes"];
    
    NSString *message;
    if (!token) {
        message = @"No token specified";
    }
    
    if (!applicantId) {
        message = @"No applicantId specified";
    }
    
    if (documentTypes && ![documentTypes isKindOfClass:[NSArray class]]) {
        message = @"invalid documentTypes type";
    }
    
    if (message) {
        return [NSError errorWithDomain:@"invalid_params"
                                   code:100
                               userInfo:@{
                                          NSLocalizedDescriptionKey: message
                                          }];
    }
    
    return nil;
}
    
+ (void)create:(id)json successCallback:(successCallback)successCallback errorCallback: (errorCallback)errorCallback {
    NSError *paramsError = [self validateParams:json];
    if (paramsError) {
        return errorCallback(paramsError);
    }
    
    NSDictionary *dictionary = [RCTConvert NSDictionary:json];
    NSString *token = dictionary[@"token"];
    NSString *applicantId = dictionary[@"applicantId"];
    NSArray *documentTypes =dictionary[@"documentTypes"];

    ONFlowConfigBuilder *configBuilder = [ONFlowConfig builder];
    [configBuilder withToken:token];
    [configBuilder withApplicantId:applicantId];
    if (documentTypes && documentTypes.count && [documentTypes[0] integerValue] != 4) {
        [configBuilder withDocumentStepOfType:[documentTypes[0] integerValue] andCountryCode:@""];
    } else {
        [configBuilder withDocumentStep];
    }

    [configBuilder withFaceStepOfVariant:ONFaceStepVariantPhoto];
    
    NSError *configError = NULL;
    ONFlowConfig *config = [configBuilder buildAndReturnError:&configError];
    
    if (configError == NULL) {
        successCallback(config);
    } else {
        errorCallback(configError);
    }
}

@end
