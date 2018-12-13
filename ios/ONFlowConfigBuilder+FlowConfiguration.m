//
//  RCTConvert+FlowConfiguration.m
//  RNOnfidoSdk
//
//  Created by Mihai Chifor on 13/12/2018.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "ONFlowConfigBuilder+FlowConfiguration.h"

@implementation ONFlowConfigBuilder (FlowConfiguration)

RCT_MULTI_ENUM_CONVERTER(ONDocumentType, (@{
                                            @"DocumentTypePassport" : @(ONDocumentTypePassport),
                                            @"DocumentTypeDrivingLicence" : @(ONDocumentTypeDrivingLicence),
                                            @"DocumentTypeNationalIdentityCard" : @(ONDocumentTypeNationalIdentityCard),
                                            @"DocumentTypeResidencePermit" : @(ONDocumentTypeResidencePermit),
                                            @"DocumentTypeAll" : @(4),
                                            }),
                         4, integerValue)
    
+ (void)create:(id)json successCallback:(successCallback)successCallback errorCallback: (errorCallback)errorCallback {
    NSDictionary *dictionary = [RCTConvert NSDictionary:json];
    NSString *token = dictionary[@"token"];
    NSString *applicantId = dictionary[@"applicantId"];

    ONFlowConfigBuilder *configBuilder = [ONFlowConfig builder];
    [configBuilder withToken:token];
    [configBuilder withApplicantId:applicantId];
    [configBuilder withDocumentStep];
//    [configBuilder withDocumentStepOfType:self->_documentType andCountryCode:@""];
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
