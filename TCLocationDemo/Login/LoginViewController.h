//
//  LoginViewController.h
//  TCLocationDemo
//
//  Created by Kristof Houben on 18/10/14.
//  Copyright (c) 2014 Treeshadow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
- (IBAction)loginWithEvernote:(id)sender;

@end
