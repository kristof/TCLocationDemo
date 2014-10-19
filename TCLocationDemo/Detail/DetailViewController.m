//
//  DetailViewController.m
//  TCLocationDemo
//
//  Created by Kristof Houben on 19/10/14.
//  Copyright (c) 2014 Treeshadow. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.noteTitle;
    self.webView.delegate = self;
    NSLog(@"%@", self.noteTitle);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"%@", self.noteRef);
    
    [[ENSession sharedSession] downloadNote:self.noteRef progress:^(CGFloat progress) {

    } completion:^(ENNote *note, NSError *downloadNoteError) {
        if (note && self.webView) {
            [self loadWebDataFromNote:note];
        } else {
            NSLog(@"Error downloading note contents %@", downloadNoteError);
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.webView = nil;
}

- (void)loadWebDataFromNote:(ENNote *)note
{
    [note generateWebArchiveData:^(NSData *data) {
        
        NSLog(@"%@", data);
        [self.webView loadData:data
                      MIMEType:ENWebArchiveDataMIMEType
              textEncodingName:nil
                       baseURL:nil];
    }];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.doneLoading = YES;
    NSString* css = @"\"* { padding:5px; background-color: #fff; color: #222; font-family: helvetica; font-size:18px; line-height:1.5em} strong{padding:0px; color:#30B250;} img{width:100%; height:auto; padding:0;}\"";
    NSString* js = [NSString stringWithFormat:
                    @"var styleNode = document.createElement('style');\n"
                    "styleNode.type = \"text/css\";\n"
                    "var styleText = document.createTextNode(%@);\n"
                    "styleNode.appendChild(styleText);\n"
                    "document.getElementsByTagName('head')[0].appendChild(styleNode);\n",css];
    NSLog(@"js:\n%@",js);
    [self.webView stringByEvaluatingJavaScriptFromString:js];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    // Don't allow user to navigate from here.
    return !self.doneLoading;
}

@end
