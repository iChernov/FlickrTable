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
#import <SDWebImage/UIImageView+WebCache.h>
#import <TMCache/TMCache.h>

static NSString * const kN4ImageCache = @"N4ImageCache";
static const int pageCount = 20;

@interface N4FlickerImageCacheInfo : NSData
@property (nonatomic,copy) NSString *url;
@property (nonatomic,copy) UIImage *image;
@end


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
    _imageSource = [N4FlickerImageSource new];
    self.tableView.rowHeight = 75.0f;
    [self.tableView registerClass:[N4FlickrImageCell class]
        forCellReuseIdentifier:NSStringFromClass([N4FlickrImageCell class])];
    [self startActivityAnimation];
    [self updatePhotos];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationItem.title = @"Recent Photos";
}

- (void)startActivityAnimation {
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
    [activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [activityView sizeToFit];
    [activityView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityView];
    [activityView startAnimating];
}

- (void)startLoadingPreviewWithPage:(int) pageNumber {
    for (int i = pageNumber*pageCount; i < (pageNumber + 1)*pageCount; i++) {
        N4FlickrImage *flickrImage = [_imageSource imageAtIndex:i];
        [self loadPreviewForImageURLString: flickrImage.imagePreviewURLString];
    }
}

- (void)loadPreviewForImageURLString:(NSString *)urlString {
    UIImage *previewImage = [_p_privateCache objectForKey:urlString];
    if (previewImage) {
        return;
    } else {
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
        AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [_p_privateCache setObject:responseObject forKey:urlString];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Image error: %@", error);
        }];
        [requestOperation start];
    }
}

- (void)updatePhotos
{
    __weak __typeof(self)weakSelf = self;
    [_imageSource fetchRecentImagesWithCompletion:^{
        [weakSelf.tableView reloadData];
        weakSelf.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updatePhotos)];
        [weakSelf startLoadingPreviewWithPage:0];
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
    
    UIImage *previewImage = [_p_privateCache objectForKey:flickrImage.imagePreviewURLString];
    if (previewImage) {
        cell.previewImageView.image = previewImage;
    } else {
        [cell.previewImageView sd_setImageWithURL:[NSURL URLWithString:flickrImage.imagePreviewURLString]
                                 placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [_p_privateCache setObject:image forKey:flickrImage.imagePreviewURLString];
                                        }];
    }
    if(indexPath.row % pageCount == 3) {
        [self startLoadingPreviewWithPage:indexPath.row/pageCount];
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
	N4FlickrImageViewController *ctrl = [[N4FlickrImageViewController alloc]
                                         initWithFlickrImage:[_imageSource imageAtIndex:indexPath.row]];
    [self.navigationController pushViewController:ctrl animated:YES];
}
@end