//
//  N4FlickrImageViewController.m
//  FlickrTable
//
//  Created by Diligent Worker on 22.04.13.
//  Copyright (c) 2013 NumberFour AG. All rights reserved.
//

#import "N4FlickrImageViewController.h"
#import "N4FlickrImage.h"
#import "AFNetworking.h"
#import "NSFavoritesManager.h"

@implementation N4FlickrImageViewController
{
    N4FlickrImage *_image;
    UIScrollView *_zoomScrollView;
    UIImageView *_imageView;
    UIActivityIndicatorView *_activityView;
}

#pragma mark - Initialization & Deallocation

- (id)initWithFlickrImage:(N4FlickrImage*)image
{
	if ((self = [super init])) {
        self.title = _image.title;
        _image = image;
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationItem.title = self.title;
    [self.view setBackgroundColor:[UIColor whiteColor]];

    [self startActivityAnimation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height-70)];
    _imageView.image = [UIImage imageNamed:@"placeholder.png"];

    _activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
    [_activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [_activityView sizeToFit];
    [_activityView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_activityView];
    
    _zoomScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _zoomScrollView.contentSize = _imageView.bounds.size;
    _zoomScrollView.delegate = self;
    _zoomScrollView.minimumZoomScale = 1.0;
    _zoomScrollView.maximumZoomScale = 4.0;
    [_zoomScrollView setZoomScale:_zoomScrollView.minimumZoomScale];
    self.view = _zoomScrollView;
    [_zoomScrollView addSubview:_imageView];
    _zoomScrollView.contentInset = UIEdgeInsetsZero;

    [self loadImage];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)startActivityAnimation {
    [_activityView startAnimating];
}

- (void)stopActivityAnimation {
    [_activityView stopAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addToFavorites)];
}

- (void)addToFavorites {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add image to favorites"
                                                    message:@"Enter comment"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *comment = [alertView textFieldAtIndex:0].text;
        NSFavoritesManager *manager = [NSFavoritesManager sharedManager];
        [manager addNewFavorite:_imageView.image withTitle:_image.title andComment:comment];
    }
}

- (void)loadImage {
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:_image.imageURLString]];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    __block UIImageView * b_imageView = _imageView;
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        b_imageView.image = responseObject;
        [self.view setNeedsDisplay];
        [self stopActivityAnimation];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Image"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [self stopActivityAnimation];
        [alertView show];
    }];
    [operation start];
}

@end