//
//  N4FlickrImageCell.m
//  FlickrTable
//
//  Created by Diligent Worker on 22.04.13.
//  Copyright (c) 2013 NumberFour AG. All rights reserved.
//

#import "N4FlickrImageCell.h"

@implementation N4FlickrImageCell
{
    UILabel *_label;
}

#pragma mark - Initialization & Deallocation

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        _previewImageView = [UIImageView new];
        _label = [UILabel new];
        [self addSubview:_label];
        [self addSubview:_previewImageView];
	}
	return self;
}



#pragma mark - Public Methods

- (void)setTitle:(NSString *)title
{
    _label.text = title;
}

- (NSString*)title
{
    return _label.text;
}


#pragma mark - UIView Methods

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _previewImageView.frame = (CGRect){0.0f, 0.0f,
        CGRectGetHeight(self.bounds), CGRectGetHeight(self.bounds)};
    _label.frame = (CGRect){CGRectGetHeight(self.bounds) + 10.0f, 0.0f,
    	CGRectGetWidth(self.bounds) - CGRectGetHeight(self.bounds) - 10.0f,
        CGRectGetHeight(self.bounds)};
}
@end