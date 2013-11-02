/*
 The MIT License (MIT)
 
 Copyright (c) 2013 Chris Pan
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */
#include <stdlib.h>

#import <FacebookSDK/FacebookSDK.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import "ViewController.h"
#import "ConfirmationViewController.h"

@interface ViewController () <MKMapViewDelegate, FBLoginViewDelegate> {
    UIImage *_selectedImage;
    BOOL _fetchedUser;
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@end

@implementation ViewController

- (NSDate *) _getMembershipDate:(NSString *)userId {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:userId];
}

- (void) _setMembershipDate:(NSString *)userId {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSDate date] forKey:userId];
    [defaults synchronize];
}

- (IBAction)_segmentControlValueChange:(id)sender
{
    [self.mapView removeAnnotations:self.mapView.annotations];

    NSString *title = [self.segmentControl titleForSegmentAtIndex:self.segmentControl.selectedSegmentIndex];
    
    for (int i = 0 ; i < 3; i++) {
        double offsetLat = (((double) arc4random()) / RAND_MAX) * .0045 * ((arc4random() % 2 == 0) ? -1 : 1);
        double offsetLong = (((double) arc4random()) / RAND_MAX) * .0045 * ((arc4random() % 2 == 0) ? -1 : 1);
        
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.coordinate = CLLocationCoordinate2DMake(self.mapView.userLocation.coordinate.latitude+offsetLat,
                                                           self.mapView.userLocation.coordinate.longitude+offsetLong);
        annotation.title = title;
        
        [self.mapView addAnnotation:annotation];
    }
}

#pragma mark - MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 2000, 2000);
    [_mapView setRegion:viewRegion animated:YES];

    [self _segmentControlValueChange:self.segmentControl];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    NSString *title = ((MKPointAnnotation *)annotation).title;
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    annotationView.canShowCallout = YES;
    if ([title isEqualToString:@"Kittens"]){
        annotationView.image = [UIImage imageNamed:@"kitten"];
    } else if ([title isEqualToString:@"Puppies"]){
        annotationView.image = [UIImage imageNamed:@"puppy"];
    } else if ([title isEqualToString:@"Lizards"]){
        annotationView.image = [UIImage imageNamed:@"lizard"];
    }
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    _selectedImage = view.image;
    [self performSegueWithIdentifier: @"SegueToConfirmation" sender: self];
}

#pragma mark - Storyboard / View lifecycle
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"SegueToConfirmation"])
	{
        NSString *title = [self.mapView.selectedAnnotations[0] title];
        ConfirmationViewController *confirmationViewController = segue.destinationViewController;
        confirmationViewController.navigationItem.title = title;
        confirmationViewController.imageToDisplay = _selectedImage;
        confirmationViewController.textToDisplay = [NSString stringWithFormat:@"Great choice, your %@ will arrive in 15 minutes and only cost $19.99!", title];
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.mapView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    // loginViewFetchedUserInfo:user: can be sent multiple times, so we use `_fetchedUser`
    // to only do work once per login.
    if (!_fetchedUser) {
        NSDate *date = [self _getMembershipDate:user[@"id"]];
        if (date) {
            [[[UIAlertView alloc] initWithTitle:@"Welcome back" message:[NSString stringWithFormat:@"member since %@", date] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        } else {
            [self _setMembershipDate:user[@"id"]];
            [[[UIAlertView alloc] initWithTitle:@"Welcome" message:@"Thanks for joining" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        }
        
    }
    _fetchedUser = YES;
}

- (void) loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    _fetchedUser = NO;
}

- (void) loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    FBRequest *request = [FBRequest requestForGraphPath:@"me/friends?fields=name,installed"];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSArray *friends = result[@"data"];
        for (NSDictionary *friend in friends) {
            if (friend[@"installed"]){
                double offsetLat = (((double) arc4random()) / RAND_MAX) * .0045 * ((arc4random() % 2 == 0) ? -1 : 1);
                double offsetLong = (((double) arc4random()) / RAND_MAX) * .0045 * ((arc4random() % 2 == 0) ? -1 : 1);
                
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                annotation.coordinate = CLLocationCoordinate2DMake(self.mapView.userLocation.coordinate.latitude+offsetLat,
                                                                   self.mapView.userLocation.coordinate.longitude+offsetLong);
                annotation.title = friend[@"name"];
                [self.mapView addAnnotation:annotation];
            }
        }
        
    }];
}

@end
