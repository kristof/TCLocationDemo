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
    self.locations = [[NSMutableArray alloc] init];
    [self findTripLocations];
    self.mapView.showsUserLocation = YES;
}

# pragma Mark — Utilities

- (void)findTripLocations {
    
    [[ENSession sharedSession] listNotebooksWithCompletion:^(NSArray *notebooks, NSError *listNotebooksError) {
        if (notebooks == 0) {
            NSLog(@"No trips");
        }else{
            [[ENSession sharedSession] findNotesWithSearch:nil
                                                inNotebook:notebooks[0]
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
                                                                
                                                                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                                                                [annotation setCoordinate:CLLocationCoordinate2DMake([note.attributes.latitude doubleValue], [note.attributes.longitude doubleValue])];
                                                                annotation.title = note.title;
                                                                
                                                                [self.mapView addAnnotation:annotation];
                                                                
                                                                NSMutableDictionary *locationDict = [[NSMutableDictionary alloc] init];
                                                                [locationDict setObject:note.title forKey:@"Title"];
                                                                [locationDict setObject:note.attributes.latitude forKey:@"Latitude"];
                                                                [locationDict setObject:note.attributes.longitude forKey:@"Longitude"];
                                                                [self.locations addObject:locationDict];
                                                                
                                                                if (findNotesResults.count == self.locations.count) {
                                                                    [self.mapView showAnnotations:self.mapView.annotations animated:YES]; 
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

- (void)showAnnotations:(NSArray *)annotations
               animated:(BOOL)animated {

}

@end
