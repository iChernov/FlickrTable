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

@implementation N4FlickerImageSource
{
    NSArray *_images;
}

- (void)fetchRecentImagesWithCompletion:(void (^)(void))completion
{
    NSString *urlString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest?method=flickr.photos.getRecent&api_key=%@&format=json&nojsoncallback=1", FLICKR_KEY];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];

    NSURLResponse *response;

    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];

    NSMutableDictionary * jsonData = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];

    NSArray *jsonImages = jsonData[@"photos"][@"photo"];

#warning We had a crash here once, but maybe just a bug with NSMutableArray?
    NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity: jsonImages.count];

    NSMutableString *imageURL;
    NSMutableString *previewURL;

    for( NSDictionary * image in jsonImages )
    {
        NSString *url = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@", image[@"farm"], image[@"server"], image[@"id"], image[@"secret"] ];

        imageURL = [[NSMutableString alloc] initWithString:url];
        [imageURL appendString:@"_b.jpg"];
        previewURL = [[NSMutableString alloc] initWithString:url];
        [previewURL appendString:@"_q.jpg"];

        N4FlickrImage * flickerImage = [[N4FlickrImage alloc] initWithTitle:image[@"title"] url:imageURL previewURL:previewURL];
        [images addObject:flickerImage];
    }

    _images = images;
    dispatch_async(dispatch_get_main_queue(), ^{
        completion();
    });
}

- (NSUInteger)count
{
    return _images.count;
}

- (N4FlickrImage*)imageAtIndex:(NSUInteger)index
{
    if( index < _images.count )
        return _images[index];
    else
        return nil;
}

@end
