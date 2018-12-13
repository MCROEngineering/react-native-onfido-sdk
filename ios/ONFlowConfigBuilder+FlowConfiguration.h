//
//  RCTConvert+FlowConfiguration.h
//  RNOnfidoSdk
//
//  Created by Mihai Chifor on 13/12/2018.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <React/RCTConvert.h>
#import <Onfido/Onfido-Swift.h>

typedef void(^successCallback)(ONFlowConfig *);
typedef void(^errorCallback)(NSError *);

@interface ONFlowConfigBuilder (FlowConfiguration)
    
+ (void)create:(id)json successCallback:(successCallback)successCallback errorCallback: (errorCallback)errorCallback;
    
@end
