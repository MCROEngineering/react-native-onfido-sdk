#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Onfido/Onfido.h>

#import "RNOnfidoSdk.h"

@interface RNOnfidoSdk () {
    NSString *_token;
    UIViewController *_rootViewController;
    RCTResponseSenderBlock _successCallback;
    RCTResponseErrorBlock _errorCallback;
    NSString *_applicantId;
    ONDocumentType _documentType;
}
@end

@implementation RNOnfidoSdk

RCT_EXPORT_MODULE(RNOnfidoSdk);

RCT_EXPORT_METHOD(startSDKWithToken:(NSString *)token applicantId:(NSString *)applicantId countryCode:(NSString *)countryCode documentType:(int)documentType successCallback:(RCTResponseSenderBlock)successCallback errorCallback:(RCTResponseErrorBlock)errorCallback) {
    ONDocumentType dType = documentType == 0
    ? ONDocumentTypePassport
    : documentType == 1 ? ONDocumentTypeDrivingLicence : ONDocumentTypeNationalIdentityCard;
    [RNOnfidoSdk startSDKWithToken:token applicantId:applicantId countryCode:countryCode documentType:dType successCallback:successCallback errorCallback:errorCallback];
}

+ (void) startSDKWithToken:(NSString *)token applicantId:(NSString *)applicantId countryCode:(NSString *)countryCode documentType:(ONDocumentType)documentType successCallback:(RCTResponseSenderBlock)successCallback errorCallback:(RCTResponseErrorBlock)errorCallback {
    
    RNOnfidoSdk *sdk = [[RNOnfidoSdk alloc] initWithToken:token applicantId:applicantId countryCode:countryCode documentType:documentType successCallback:successCallback errorCallback:errorCallback];
    [sdk run];
}

- (id) initWithToken:(NSString *)token applicantId:(NSString *)applicantId countryCode:(NSString *)countryCode documentType:(ONDocumentType)documentType successCallback:(RCTResponseSenderBlock)successCallback errorCallback:(RCTResponseErrorBlock)errorCallback {
    self = [super init];
    
    if (self) {
        _token = token;
        _successCallback = successCallback;
        _errorCallback = errorCallback;
        _documentType = documentType;
        _applicantId = applicantId;
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
        //        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        _rootViewController = (UIViewController *)window.rootViewController;
        
        if (_applicantId) {
            ONFlowConfigBuilder *configBuilder = [ONFlowConfig builder];
            [configBuilder withToken:_token];
            [configBuilder withApplicantId:_applicantId];
            [configBuilder withDocumentStepOfType:_documentType andCountryCode:@""];
            [configBuilder withFaceStepOfVariant:ONFaceStepVariantPhoto];
            
            NSError *configError = NULL;
            ONFlowConfig *config = [configBuilder buildAndReturnError:&configError];
            
            if (configError == NULL) {
                [self runSDKFlowWithConfig:config];
            } else {
                UIAlertController *popup = [self createErrorPopupWithMessage:[NSString stringWithFormat:@"unable to run flow %@", [[configError userInfo] valueForKey:@"message"]]];
                
                [_rootViewController presentViewController:popup animated:YES completion:NULL];
            }
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
