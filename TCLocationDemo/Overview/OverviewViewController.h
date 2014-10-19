//
//  OverviewViewController.h
//  TCLocationDemo
//
//  Created by Kristof Houben on 19/10/14.
//  Copyright (c) 2014 Treeshadow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OverviewViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *notebooks;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end
