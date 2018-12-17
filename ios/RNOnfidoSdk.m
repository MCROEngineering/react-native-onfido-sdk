#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <React/RCTConvert.h>
#import <Onfido/Onfido-Swift.h>

#import "ONFlowConfigBuilder+FlowConfiguration.h"
#import "RNOnfidoSdk.h"
#import "CustomFlowViewController.h"

@interface RNOnfidoSdk () {
    id _params;
    UIViewController *_rootViewController;
    RCTResponseSenderBlock _successCallback;
    RCTResponseErrorBlock _errorCallback;
}
@end

@implementation RNOnfidoSdk
    
RCT_EXPORT_MODULE();

- (NSDictionary *)constantsToExport
    {
        return @{
                 @"DocumentTypePassport" : @(0),
                 @"DocumentTypeDrivingLicence" : @(1),
                 @"DocumentTypeNationalIdentityCard" : @(2),
                 @"DocumentTypeResidencePermit" : @(3),
                 @"DocumentTypeAll" : @(4)
                 };
    };

    
RCT_EXPORT_METHOD(startSDK:(id)json successCallback:(RCTResponseSenderBlock)successCallback errorCallback:(RCTResponseErrorBlock)errorCallback) {
    RNOnfidoSdk *sdk = [[RNOnfidoSdk alloc] initWithParams:json successCallback:successCallback errorCallback:errorCallback];
    [sdk run];
}

- (id)initWithParams:(id)params successCallback:(RCTResponseSenderBlock)successCallback errorCallback:(RCTResponseErrorBlock)errorCallback {
    self = [super init];

    if (self) {
        _successCallback = successCallback;
        _errorCallback = errorCallback;
        _params = params;
    }

    return self;
}

/**
 Runs Onfido SDK Flow
 */
- (void) run {

    dispatch_async(dispatch_get_main_queue(), ^{

        // Get view controller on which to present the flow
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        self->_rootViewController = (UIViewController *)window.rootViewController;
        
        NSDictionary *dictionary = [RCTConvert NSDictionary:self->_params];
        @try {
            NSArray *flowSteps = dictionary[@"flowSteps"];
            if (flowSteps && flowSteps.count > 1) {
                CustomFlowViewController *customFlowVC = [[CustomFlowViewController alloc] initWithParams:self->_params];
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController: customFlowVC];
                [navController.navigationBar setBarTintColor:UIColor.whiteColor];
                [navController.navigationBar setValue:@(YES) forKeyPath:@"hidesShadow"];
                [self->_rootViewController presentViewController:navController animated:true completion:nil];
            } else {
                [ONFlowConfigBuilder create:self->_params successCallback:^(ONFlowConfig *config) {
                    [self runSDKFlowWithConfig:config];
                } errorCallback:^(NSError *error) {
                    UIAlertController *popup = [self createErrorPopupWithMessage:[error localizedDescription]];
                    [self->_rootViewController presentViewController:popup animated:YES completion:NULL];
                }];
            }
        } @catch (NSException *e) {
            self->_errorCallback([NSError errorWithDomain:@"invalid_params" code:100 userInfo:@{                                                                                               NSLocalizedDescriptionKey: @"Invalid flowSteps type"
                                                                                               }]);
        }
    });
}

- (void) runSDKFlowWithConfig: (ONFlowConfig *) config {

    ONFlow *flow = [[ONFlow alloc] initWithFlowConfiguration:config];

    // register callback handler
    [flow withResponseHandler:^(ONFlowResponse * _Nonnull response) {
        // more on handling callbacks https://github.com/onfido/onfido-ios-sdk#handling-callbacks
        [self handleFlowResponse:response];
    } dismissFlowOnCompletion: false];

    NSError *runError = NULL;
    UIViewController *flowVC = [flow runAndReturnError:&runError];

    if (runError == NULL) { //more on run exceptions https://github.com/onfido/onfido-ios-sdk#run-exceptions
        [_rootViewController presentViewController:flowVC animated:YES completion:nil];
    } else {
        // Flow may not run
        NSLog(@"Run error %@", [[runError userInfo] valueForKey:@"message"]);
    }
}

- (void) handleFlowResponse: (ONFlowResponse *) response {

    [_rootViewController dismissViewControllerAnimated:YES completion:^{

        if (response.error) {

            // Flow encountered error
            [self handleFlowError:response.error];

        } else if (response.userCanceled) {

            // Flow was canceled by the user
            //      [self handleUserFlowCancelation];

        } else if (response.results) {

            // Flow ran successfuly and produced results
            [self handleFlowResults:response.results];
        }
    }];
}

- (NSDictionary *)documentToDictionary: (ONDocumentResult *)document {
    return @{@"href" : document.href, @"createdAt": document.createdAt, @"fileName": document.fileName, @"fileType": document.fileType, @"fileSize": document.fileSize, @"type": document.type, @"side": document.side, @"description": document.description};
}

- (NSDictionary *)faceToDictionary: (ONFaceResult *)faceResult {
    return @{@"href" : faceResult.href, @"createdAt": faceResult.createdAt, @"fileName": faceResult.fileName, @"fileType": faceResult.fileType, @"fileSize": faceResult.fileSize, @"description": faceResult.description};
}

- (void) handleFlowResults: (NSArray *) results {
    _successCallback(@[]);
    [_rootViewController.view endEditing:YES];
}

- (void) handleFlowError: (NSError *) error {
    UIAlertController *errorPopup;
    if (error.code == ONFlowErrorCameraPermission) {
        errorPopup = [self createErrorPopupWithMessage:@"Camera permission denied"];
    } else {
        errorPopup = [self createErrorPopupWithMessage:@"Unhandled error"];
    }

    _errorCallback(error);
    [_rootViewController presentViewController:errorPopup animated:YES completion:NULL];
}

- (void) handleUserFlowCancelation {

    [_rootViewController presentViewController:[self createUserCanceledPopup] animated:YES completion:NULL];
}

- (UIAlertController *)createErrorPopupWithMessage: (NSString *) errorMessage {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];

    return alert;
}

- (UIAlertController *)createFlowRunSuccessPopup {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success" message:@"The SDK flow ran successfully" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];

    return alert;
}

- (UIAlertController *)createUserCanceledPopup {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Canceled" message:@"The SDK flow was canceled  by the user" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];

    return alert;
}

@end
