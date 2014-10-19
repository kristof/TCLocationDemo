//
//  MapViewController.m
//  TCLocationDemo
//
//  Created by Kristof Houben on 18/10/14.
//  Copyright (c) 2014 Treeshadow. All rights reserved.
//

#import "MapViewController.h"
#import <ENSDK/ENSDK.h>
#import <ENSDK/Advanced/ENSDKAdvanced.h>

@interface MapViewController ()

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.showsUserLocation = YES;
    
    for(id location in self.locations){
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [annotation setCoordinate:CLLocationCoordinate2DMake([[location valueForKey:@"Latitude"] doubleValue], [[location valueForKey:@"Longitude"] doubleValue])];
        annotation.title = [location valueForKey:@"Title"];
        [self.mapView addAnnotation:annotation];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
}

- (IBAction)closeModal:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
