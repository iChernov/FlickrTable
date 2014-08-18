//
//  N4FlickrImage.h
//  FlickrTable
//
//  Created by Christian Lippka on 7/29/13.
//  Copyright (c) 2013 NumberFour AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface N4FlickrImage : NSObject
@property (nonatomic,copy,readonly) NSString *title;
@property (nonatomic,copy,readonly) NSString *url;
@property (nonatomic,copy,readonly) NSString *previewURL;

- (id)initWithTitle:(NSString*)title url:(NSString*)url previewURL:(NSString*)previewURL;
@end
