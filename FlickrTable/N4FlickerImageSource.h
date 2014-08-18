//
//  N4FlickerImageSource.h
//  FlickrTable
//
//  Created by Diligent Worker on 22.04.13.
//  Copyright (c) 2013 NumberFour AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class N4FlickrImage;

@interface N4FlickerImageSource : NSObject

@property (nonatomic,assign,readonly) NSUInteger count;

- (void)fetchRecentImagesWithCompletion:(void (^)(void))completion;

- (N4FlickrImage*)imageAtIndex:(NSUInteger)index;

@end
