//
//  TripViewController.h
//  TCLocationDemo
//
//  Created by Kristof Houben on 18/10/14.
//  Copyright (c) 2014 Treeshadow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface TripViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *findNotesResults;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLCircularRegion *someRegion;

@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) NSMutableDictionary *notebook;


- (IBAction)openMap:(id)sender;

@end
