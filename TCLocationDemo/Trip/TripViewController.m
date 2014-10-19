//
//  TripViewController.m
//  TCLocationDemo
//
//  Created by Kristof Houben on 18/10/14.
//  Copyright (c) 2014 Treeshadow. All rights reserved.
//

#import "TripViewController.h"
#import <ENSDK/ENSDK.h>
#import <ENSDK/Advanced/ENSDKAdvanced.h>
#import "LocationTableViewCell.h"
#import "MapViewController.h"

@interface TripViewController ()

@end

@implementation TripViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locations = [[NSMutableArray alloc] init];
    
    // Initialize Refresh Control
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor lightGrayColor];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self findTripLocations];
    
    self.title = [self.notebook valueForKey:@"Name"];
    
    
    // Location manager
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestAlwaysAuthorization];
    self.locationManager.delegate = self;
}

#pragma mark - Refresh

- (void)refresh:(id)sender
{
    self.locations = [[NSMutableArray alloc] init];
    [self findTripLocations];
}

#pragma mark - TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.findNotesResults) {
        return self.findNotesResults.count;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LocationTableViewCell *cell = (LocationTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"LocationTableViewCell"];
    [self configureCell:cell forRowAtIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(LocationTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.titleLabel.text = [self.locations[indexPath.row] objectForKey:@"Title"];
}

# pragma Mark — Utilities

- (void)findTripLocations {
    
    [[ENSession sharedSession] listNotebooksWithCompletion:^(NSArray *notebooks, NSError *listNotebooksError) {
        if (notebooks == 0) {
            NSLog(@"No trips");
        }else{
            [[ENSession sharedSession] findNotesWithSearch:nil
                                                inNotebook:(ENNotebook *)[self.notebook objectForKey:@"Object"]
                                                   orScope:ENSessionSearchScopeNone
                                                 sortOrder:ENSessionSortOrderRecentlyCreated
                                                maxResults:0
                                                completion:^(NSArray *findNotesResults, NSError *findNotesError) {
                                                    if (!findNotesResults) {
                                                        if ([findNotesError.domain isEqualToString:ENErrorDomain] &&
                                                            findNotesError.code == ENErrorCodePermissionDenied) {
                                                            NSLog(@"Permission denied for note find. Maybe your app only has read access?");
                                                        } else {
                                                            NSLog(@"Error searching for notes");
                                                        }
                                                        NSLog(@"findNotesError: %@", findNotesError);
                                                    } else if (findNotesResults.count == 0) {
                                                        NSLog(@"No notes from this app! Go back to menu to create some.");
                                                    } else {
                                                        self.findNotesResults = findNotesResults;
                                                        
                                                        for (id findNotesResult in findNotesResults) {
                                                            ENSessionFindNotesResult *result = findNotesResult;
                                                            
                                                            ENNoteStoreClient *noteStore = [[ENSession sharedSession] noteStoreForNoteRef:result.noteRef];
                                                            
                                                            [noteStore getNoteWithGuid:result.noteRef.guid withContent:NO withResourcesData:NO withResourcesRecognition:NO withResourcesAlternateData:NO success:^(EDAMNote *note) {
                                                                
                                                                NSLog(@"Notes: %@", note.title);
                                                                
                                                                NSMutableDictionary *locationDict = [[NSMutableDictionary alloc] init];
                                                                [locationDict setObject:note.title forKey:@"Title"];
                                                                [locationDict setObject:note.attributes.latitude forKey:@"Latitude"];
                                                                [locationDict setObject:note.attributes.longitude forKey:@"Longitude"];
                                                                [locationDict setObject:note.created forKey:@"Created"];
                                                                [self.locations addObject:locationDict];
                                                                
                                                                if (findNotesResults.count == self.locations.count) {
                                                                    NSLog(@"%@", self.locations);
                                                                    
                                                                    NSSortDescriptor *sortDes = [[NSSortDescriptor alloc] initWithKey:@"Created" ascending:NO];
                                                                    [self.locations sortUsingDescriptors:[NSArray arrayWithObject:sortDes]];
                                                                    
                                                                    //[self setupLocationManager];
                                                                    
                                                                    [self.tableView reloadData];
                                                                    [self.refreshControl endRefreshing];
                                                                }
                                                                
                                                            } failure:^(NSError *error) {
                                                                // Error
                                                            }];
                                                        }
                                                        
                                                    }
                                                }];
        }
    }];
}

- (void) setupLocationManager {
    for (id location in self.locations) {
        CLLocationDistance radius = 1000; //1KM
        CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake([[location objectForKey:@"Latitude"] doubleValue], [[location objectForKey:@"Longitude"] doubleValue]) radius:radius identifier:@"Tower Bridge"];
        [self.locationManager startMonitoringForRegion:region];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 100;
        [self.locationManager startUpdatingLocation];
    }
    
     NSLog(@"monotoring regions:%@", self.locationManager.monitoredRegions);
}

# pragma Mark — LocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* location = [locations lastObject];
    
    // If the user's current location is not within the region anymore, stop updating
    if ([self.someRegion containsCoordinate:location.coordinate] == NO) {
        [self.locationManager stopUpdatingLocation];
    }
    
    NSString *locationData = [NSString stringWithFormat:@"latitude %+.6f, longitude %+.6f\n",
                              location.coordinate.latitude,
                              location.coordinate.longitude];
    NSLog(@"%@", locationData);
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = locationData;
    localNotification.alertAction = @"Location data received";
    localNotification.hasAction = YES;
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"MapSegue"])
    {
        MapViewController *mapViewController = (MapViewController *)[[segue destinationViewController] topViewController];
        mapViewController.locations = self.locations;
    }
}

- (IBAction)openMap:(id)sender {
    [self performSegueWithIdentifier:@"MapSegue" sender:sender];
}
@end
