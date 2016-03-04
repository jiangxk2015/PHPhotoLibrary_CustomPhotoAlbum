//
//  PHPhotoLibrary+CustomPhotoAlbum.h
//  PHAsset_CustomPhotoAlbum
//
//  Created by jiangxk on 16/3/3.
//  Copyright © 2016年 蒋先科. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

typedef void(^PHAssetLibraryWriteImageCompletionBlock)(PHAsset *imageAsset);

typedef void(^PHAssetLibraryWriteVideoCompletionBlock)(NSURL *videoUrl);

typedef void(^PHAssetLibraryAccessFailureBlock)(NSError *error);

@interface PHPhotoLibrary (CustomPhotoAlbum)

// 创建一个相册
- (PHAssetCollection *)createNewAlbumCalled:(NSString *)albumName;

/**
 *  保存一个UIImage对象到某一个相册里，若没有该相册会先自动创建
 *
 *  @param image
 *  @param albumName
 *  @param completion
 *  @param failure
 */
- (void)saveImage:(UIImage *)image ToAlbum:(NSString *)albumName completion:(PHAssetLibraryWriteImageCompletionBlock)completion failure:(PHAssetLibraryAccessFailureBlock)failure;

/**
 *  通过一个图片的本地url保存该图片到某一个相册里
 *
 *  @param imageUrl
 *  @param albumName
 *  @param completion
 *  @param failure
 */
- (void)saveImageWithImageUrl:(NSURL *)imageUrl ToAlbum:(NSString *)albumName completion:(PHAssetLibraryWriteImageCompletionBlock)completion failure:(PHAssetLibraryAccessFailureBlock)failure;

/**
 *  通过一个视频的本地url保存该视频到某一个相册里
 *
 *  @param videoUrl
 *  @param albumName
 *  @param completion
 *  @param failure
 */
- (void)saveVideoWithUrl:(NSURL *)videoUrl ToAlbum:(NSString *)albumName completion:(PHAssetLibraryWriteVideoCompletionBlock)completion failure:(PHAssetLibraryAccessFailureBlock)failure;

/**
 *  保存一个imageData对象到某一个相册里
 *
 *  @param phasset
 *  @param albumName
 *  @param completion
 *  @param failure
 */
- (void)saveImageData:(NSData *)imageData ToAlbum:(NSString *)albumName completion:(PHAssetLibraryWriteImageCompletionBlock)completion failure:(PHAssetLibraryAccessFailureBlock)failure;


/**
 *  获取photos app创建的相册里所有图片
 *
 *  @param albumName
 *  @param completion
 */
- (void)loadImagesFromAlbum:(NSString *)albumName completion:(void (^)(NSMutableArray *images, NSError *error))completion;


@end
