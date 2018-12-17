//
//  CustomFlowContainerViewController.m
//  react-native-onfido-sdk
//
//  Created by Mihai Chifor on 17/12/2018.
//

#import "CustomFlowContainerViewController.h"

@interface CustomFlowContainerViewController ()

@property (nonatomic, strong) UINavigationController *navController;

@end

@implementation CustomFlowContainerViewController

- (id)initWithNavController: (UINavigationController *)navController {
    self = [super init];
    if (self) {
        self.navController = navController;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navController willMoveToParentViewController:self];
    
    self.navController.view.frame = self.view.frame;
    [self.view addSubview:self.navController.view];
    [self addChildViewController: self.navController];
    [self.navController didMoveToParentViewController:self];
}

@end
