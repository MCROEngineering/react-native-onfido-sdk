//
//  CustomFlowViewController.m
//  react-native-onfido-sdk
//
//  Created by Mihai Chifor on 14/12/2018.
//

#import <React/RCTConvert.h>
#import <Onfido/Onfido-Swift.h>
#import "CustomFlowViewController.h"
#import "ONFlowConfigBuilder+FlowConfiguration.h"
#import "CustomFlowContainerViewController.h"

@interface CustomFlowViewController ()

@property (nonatomic, strong) NSDictionary *params;

@end

@implementation CustomFlowViewController

- (id) initWithParams:(id)params {
    self = [super init];
    if (self) {
        self.params = [RCTConvert NSDictionary:params];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;

    [self configureNavigationBar];
    [self setupContent];
}

- (void)configureNavigationBar {
    self.navigationItem.title = @"Identity verification";
    self.navigationController.navigationBar.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backButtonPressed:)];
}

- (NSString *)titleForOption:(NSInteger)option {
    NSString *title;
    switch (option) {
        case 0:
            title = @"Passport";
            break;
        case 1:
            title = @"Driver's License";
            break;
        case 2:
            title = @"National Identity Card";
            break;
        case 3:
            title = @"Residence Permit Card";
            break;
        default:
            title = @"";
            break;
    }
    return title;
}

- (UIImage *)imageForDocumentType: (NSInteger) documentType {
    NSString *imageName;
    switch (documentType) {
        case 0:
            imageName = @"passport";
            break;
        case 1:
            imageName = @"driving_licence";
            break;
        case 2:
            imageName = @"national_id";
            break;
        case 3:
            imageName = @"residence_card";
            break;
        default: break;
    }
    
    NSBundle *bundle = [self getResourcesBundle];
    return [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
}

- (NSBundle *)getResourcesBundle {
    NSString *resourcePath = [NSBundle.mainBundle pathForResource:@"Resources" ofType:@"bundle"];
    return [NSBundle bundleWithPath:resourcePath];
}

- (void)setupContent {
    // title
    CGRect titleRect = CGRectMake(24, 92, CGRectGetWidth(self.view.frame) - 32, 27);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleRect];
    titleLabel.font = [UIFont systemFontOfSize:27 weight:UIFontWeightSemibold];
    titleLabel.text = @"Select a document";
    [self.view addSubview:titleLabel];

    // subtitle
    CGRect subtitleRect = CGRectMake(titleRect.origin.x, titleRect.origin.y + 44, titleRect.size.width, titleRect.size.height);
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:subtitleRect];
    subtitleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightLight];
    subtitleLabel.textColor = UIColor.grayColor;
    subtitleLabel.text = @"You will take a picture of it in the next step";
    [self.view addSubview:subtitleLabel];

    // options
    NSArray *documentTypes = self.params[@"documentTypes"];
    for (int i = 0; i < documentTypes.count; i += 1) {
        NSInteger documentType = [documentTypes[i] integerValue];

        NSInteger cellHeight = 108;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        CGRect buttonFrame = CGRectMake(0, subtitleRect.origin.y + 50 + (i * cellHeight), CGRectGetWidth(self.view.frame), cellHeight);
        button.frame = buttonFrame;
        button.tag = documentType;
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];

        CGRect imageViewContainerRect = CGRectMake(24, 24, 60, 60);
        UIView *imageViewContainer = [[UIView alloc] initWithFrame:imageViewContainerRect];
        CGRect imageViewRect = CGRectMake(16, 16, 28, 28);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageViewRect];
        imageViewContainer.layer.cornerRadius = 10;
        imageViewContainer.backgroundColor = [UIColor colorWithRed:63.0f/255.0f green:93.0f/255.0f blue:138.0f/255.0f alpha:1];
        imageView.image = [self imageForDocumentType:documentType];
        [imageViewContainer addSubview:imageView];
        
        CGRect buttonTitleRect = CGRectMake(CGRectGetMaxX(imageViewContainerRect) + 16, 44, CGRectGetWidth(buttonFrame)- (CGRectGetMaxX(imageViewContainerRect) + 24 * 3), 20);
        UILabel *buttonTitleLabel = [[UILabel alloc] initWithFrame:buttonTitleRect];
        buttonTitleLabel.text = [self titleForOption: documentType];

        UIImageView *arrowRightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(buttonFrame) - 32, 44, 12, 20)];
        NSBundle *bundle = [self getResourcesBundle];
        UIImage *arrowRightImage = [UIImage imageNamed:@"arrow_right" inBundle:bundle compatibleWithTraitCollection:nil];
        arrowRightImageView.image = arrowRightImage;

        [button addSubview:imageViewContainer];
        [button addSubview:buttonTitleLabel];
        [button addSubview:arrowRightImageView];

        [self.view addSubview:button];
    }
}

- (void)backButtonPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)buttonClicked:(UIButton *)sender {
    [self.params setValue:@[@(sender.tag)] forKey:@"documentTypes"];
    [ONFlowConfigBuilder create:self.params successCallback:^(ONFlowConfig *config) {
        ONFlow *flow = [[ONFlow alloc] initWithFlowConfiguration:config];

        [flow withResponseHandler:^(ONFlowResponse * _Nonnull response) {
            // more on handling callbacks https://github.com/onfido/onfido-ios-sdk#handling-callbacks
            [self handleFlowResponse:response];
        } dismissFlowOnCompletion: false];

        NSError *runError = NULL;
        UIViewController *flowVC = [flow runAndReturnError:&runError];


        if (runError == NULL) {
            UINavigationController *onfidoNavigationController = (UINavigationController *)flowVC;
            UIViewController *vc = [[CustomFlowContainerViewController alloc] initWithNavController:onfidoNavigationController];
            [self.navigationController pushViewController: vc animated:true];
        } else {
            NSLog(@"Run error %@", [[runError userInfo] valueForKey:@"message"]);
        }
    } errorCallback:^(NSError *error) {

    }];
}

- (void) handleFlowResponse: (ONFlowResponse *) response {
    if (response.error) {



    } else if (response.userCanceled) {



    } else if (response.results) {


    }
}

@end
