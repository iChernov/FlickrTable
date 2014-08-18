//
//  N4FlickerImageSource.m
//  FlickrTable
//
//  Created by Diligent Worker on 22.04.13.
//  Copyright (c) 2013 NumberFour AG. All rights reserved.
//

#import "N4FlickerImageSource.h"
#import "N4FlickrConstants.h"
#import "N4FlickrImage.h"
#import "AFNetworking.h"

static NSString * const BaseURLString = @"https://api.flickr.com/services/rest?method=flickr.photos.getRecent";

@interface N4FlickerImageSource ()
@property (strong, nonatomic) NSArray *p_images; //previously, as an instance variable, was never initialized
@end

@implementation N4FlickerImageSource

- (void)fetchRecentImagesWithCompletion:(void (^)(void))completion
{
    __weak __typeof(self)weakSelf = self;
    NSString *urlString = [NSString stringWithFormat:@"%@&api_key=%@&format=json&nojsoncallback=1", BaseURLString, FLICKR_KEY];
    // it could be not really reasonable to keep FLICKR_KEY in a separate file, but that is rather moot point

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *jsonImages = responseObject[@"photos"][@"photo"];
        if (jsonImages.count > 0) {
            NSMutableArray *imagesArray = [[NSMutableArray alloc] initWithCapacity: jsonImages.count];
            NSString *imageTitle;
            NSString *imageURL; //absolutely no need to make them mutable
            NSString *previewURL; //absolutely no need to make them mutable
            for( NSDictionary * imageDictionary in jsonImages )
            {
                NSString *imageUrlString = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@", imageDictionary[@"farm"], imageDictionary[@"server"], imageDictionary[@"id"], imageDictionary[@"secret"]];
                imageTitle = [NSString stringWithString: imageDictionary[@"title"]];
                imageURL = [NSString stringWithFormat:@"%@_b.jpg", imageUrlString];
                previewURL = [NSString stringWithFormat:@"%@_q.jpg", imageUrlString];
                
                N4FlickrImage * flickerImage = [[N4FlickrImage alloc] initWithTitle:imageTitle url:imageURL previewURL:previewURL];
                //however, here ^^^ we also should pass NSStrings, not NSMutableStrings
                [imagesArray addObject:flickerImage];
            }
            weakSelf.p_images = [imagesArray copy];
            //it is rather bad practice just to assign NSMutableArray pointer to the NSArray pointer, as was done previously (_images = images)
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Images"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    [operation start];
}

- (NSUInteger)count
{
    return _p_images.count;
}

- (N4FlickrImage*)imageAtIndex:(NSUInteger)index
{
    if( index < _p_images.count )
        return _p_images[index];
    else
        return nil;
}

@end
