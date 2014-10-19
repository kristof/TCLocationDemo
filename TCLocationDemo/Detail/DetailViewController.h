//
//  DetailViewController.h
//  TCLocationDemo
//
//  Created by Kristof Houben on 19/10/14.
//  Copyright (c) 2014 Treeshadow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ENSDK/ENSDK.h>

@interface DetailViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) ENNoteRef * noteRef;
@property (nonatomic, strong) NSString * noteTitle;
@property (nonatomic, assign) BOOL doneLoading;

@end
