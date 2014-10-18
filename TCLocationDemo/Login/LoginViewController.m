//
//  LoginViewController.m
//  TCLocationDemo
//
//  Created by Kristof Houben on 18/10/14.
//  Copyright (c) 2014 Treeshadow. All rights reserved.
//

#import "LoginViewController.h"
#import <ENSDK/ENSDK.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[ENSession sharedSession] isAuthenticated]) {
        [self performSegueWithIdentifier: @"LoginSegue" sender: self];
    }

}

- (IBAction)loginWithEvernote:(id)sender {
    ENSession *session = [ENSession sharedSession];
    [session authenticateWithViewController:self preferRegistration:NO completion:^(NSError *error) {
        if (error) {
            NSLog(@"Error");
        } else {
            [self performSegueWithIdentifier: @"LoginSegue" sender: self];
        }
    }];
}

@end