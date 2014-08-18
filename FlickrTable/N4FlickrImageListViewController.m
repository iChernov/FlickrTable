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
#import <SDWebImage/UIImageView+WebCache.h>

@interface N4FlickerImageCacheInfo : NSData
@property (nonatomic,copy) NSString *url;
@property (nonatomic,copy) UIImage *image;
@end


@implementation N4FlickerImageCacheInfo
@end

@interface N4FlickrImageListViewController ()
@end


@implementation N4FlickrImageListViewController
{
    N4FlickerImageSource *_imageSource;
}


- (id)init
{
    self = [super init];
    if(!self)
    {
        return nil;
    }
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
    [cell.previewImageView setImageWithURL:[NSURL URLWithString:flickrImage.imagePreviewURLString]
                   placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
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