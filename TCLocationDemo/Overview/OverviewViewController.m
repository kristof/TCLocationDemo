//
//  OverviewViewController.m
//  TCLocationDemo
//
//  Created by Kristof Houben on 19/10/14.
//  Copyright (c) 2014 Treeshadow. All rights reserved.
//

#import "OverviewViewController.h"
#import "LocationTableViewCell.h"
#import <ENSDK/ENSDK.h>
#import <ENSDK/Advanced/ENSDKAdvanced.h>
#import "TripViewController.h"

@interface OverviewViewController ()

@end

@implementation OverviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.notebooks = [[NSMutableArray alloc] init];
    
    [self findNotebooks];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Initialize Refresh Control
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor lightGrayColor];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

#pragma mark - Refresh

- (void)refresh:(id)sender
{
    self.notebooks = [[NSMutableArray alloc] init];
    [self findNotebooks];
}

#pragma mark - TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.notebooks) {
        return self.notebooks.count;
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
    
    NSLog(@"%@", [self.notebooks[indexPath.row] objectForKey:@"Name"]);
    cell.titleLabel.text = [self.notebooks[indexPath.row] objectForKey:@"Name"];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"TripSegue"]){
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        TripViewController *tripViewController = segue.destinationViewController;
        tripViewController.notebook = self.notebooks[indexPath.row];
    }
}

# pragma Mark — Utilities

- (void)findNotebooks {
    
    [[ENSession sharedSession] listNotebooksWithCompletion:^(NSArray *notebooks, NSError *listNotebooksError) {
        if (notebooks == 0) {
            NSLog(@"No trips");
        }else{
            for (id notebook in notebooks) {
                ENNotebook *noteObject = (ENNotebook *)notebook;
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                [dict setObject:noteObject.name forKey:@"Name"];
                [dict setObject:noteObject forKey:@"Object"];
                [self.notebooks addObject:dict];
            }
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        }
    }];
}

@end
