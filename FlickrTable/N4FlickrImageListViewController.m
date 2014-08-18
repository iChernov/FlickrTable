//
//  N4FlickrImageListViewController.m
//  FlickrTable
//
//  Created by Diligent Worker on 22.04.13.
//  Copyright (c) 2013 NumberFour AG. All rights reserved.
//

#import "N4FlickrImageListViewController.h"

#import "N4FlickrConstants.h"
#import "N4FlickerImageSource.h"
#import "N4FlickrImageCell.h"
#import "N4FlickrImageViewController.h"
#import "N4FlickrImage.h"
#import "AFNetworking.h"
#import <TMCache/TMCache.h>

@interface N4FlickerImageCacheInfo : NSData
@property (nonatomic,copy) NSString *url;
@property (nonatomic,copy) UIImage *image;
@end

static NSString * const kN4ImageCache = @"N4ImageCache";

@implementation N4FlickerImageCacheInfo
@end

@interface N4FlickrImageListViewController ()
@property (strong, nonatomic) TMCache *p_privateCache;
@end


@implementation N4FlickrImageListViewController
{
    N4FlickerImageSource *_imageSource;
}

+ (id)sharedCache {
    static dispatch_once_t pred;
    __strong static TMCache *_sharedCache = nil;
    dispatch_once(&pred, ^{
        _sharedCache = [[TMCache alloc] initWithName:kN4ImageCache];
    });
    return _sharedCache;
}

- (id)init
{
    self = [super init];
    if(!self)
    {
        return nil;
    }
    _p_privateCache = [N4FlickrImageListViewController sharedCache];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = 75.0f;
    [self.tableView registerClass:[N4FlickrImageCell class]
        forCellReuseIdentifier:NSStringFromClass([N4FlickrImageCell class])];

    _imageSource = [N4FlickerImageSource new];
}

- (void)viewWillAppear:(BOOL)animated {
    [self startActivityAnimation];
    self.navigationItem.title = @"Recent Photos";
    [self updatePhotos];
}

- (void)startActivityAnimation {
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
    [activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [activityView sizeToFit];
    [activityView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityView];
    [activityView startAnimating];
}

- (void)updatePhotos
{
    __weak __typeof(self)weakSelf = self;
    [_imageSource fetchRecentImagesWithCompletion:^{
        [weakSelf.tableView reloadData];
        weakSelf.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updatePhotos)];
    }];
}

#pragma mark - UITableView DataSource/Delegate methods

- (UITableViewCell *)tableView:(UITableView *)tableView
	cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	N4FlickrImageCell *cell = [tableView dequeueReusableCellWithIdentifier:
        NSStringFromClass([N4FlickrImageCell class])];
    N4FlickrImage *flickrImage = [_imageSource imageAtIndex:indexPath.row];
    
    cell.title = flickrImage.title;
    cell.previewImage = nil;

    N4FlickerImageCacheInfo *currentImageCacheInfo; //just "found" = bad naming, seems like it is a BOOL value

    // search our cache if we already downloaded this image
    currentImageCacheInfo = [_p_privateCache objectForKey:flickrImage.imagePreviewURLString];

    if(currentImageCacheInfo)
    {
        // we already downloaded this image, we can use it now
        cell.previewImage = currentImageCacheInfo.image;
    }
    else
    {
        // we have not downloaded this image, download it now and add to cache
        // but we have to do that in a background!
        currentImageCacheInfo = [N4FlickerImageCacheInfo new];
        currentImageCacheInfo.url = flickrImage.imagePreviewURLString;
        [_p_privateCache setObject:currentImageCacheInfo forKey:flickrImage.imagePreviewURLString];

        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:flickrImage.imagePreviewURLString]];
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFImageResponseSerializer serializer];
        
        __block N4FlickerImageCacheInfo *b_currentImageCacheInfo = currentImageCacheInfo;
        __block N4FlickrImageCell *b_cell = cell;
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            b_currentImageCacheInfo.image = responseObject;
            dispatch_async(dispatch_get_main_queue(), ^{
                b_cell.previewImage = currentImageCacheInfo.image;
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        }];
        [operation start];
    }
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _imageSource.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // show the selected image in our image view controller
#warning presenting this causes a delay and the app hangs, maybe we can fix it?
	N4FlickrImageViewController *ctrl = [[N4FlickrImageViewController alloc]
                                         initWithFlickrImage:[_imageSource imageAtIndex:indexPath.row]];
    [self.navigationController pushViewController:ctrl animated:YES];
}
@end