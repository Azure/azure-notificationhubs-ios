//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "ViewController.h"
#import "AppDelegate.h"
#import "Constants.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Load raw tags text from storage and initialize the text field
    self.tagsTextField.text = [[NSUserDefaults standardUserDefaults] valueForKey:NHUserDefaultTags];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (IBAction)handleRegister:(id)sender {
    // Save raw tags text in storage
    [[NSUserDefaults standardUserDefaults] setValue:self.tagsTextField.text forKey:NHUserDefaultTags];

    [[[UIApplication sharedApplication] delegate] performSelector:@selector(handleRegister)];
}

- (IBAction)handleUnregister:(id)sender {
    //
    // Delegate processing the unregister action to the app delegate.
    //
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(handleUnregister)];
}

@end
