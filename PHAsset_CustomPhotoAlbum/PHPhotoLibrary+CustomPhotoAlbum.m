//
//  PHPhotoLibrary+CustomPhotoAlbum.m
//  PHAsset_CustomPhotoAlbum
//
//  Created by jiangxk on 16/3/3.
//  Copyright © 2016年 蒋先科. All rights reserved.
//

#import "PHPhotoLibrary+CustomPhotoAlbum.h"


typedef enum : NSUInteger {
    ImageTpye = 1,
    ImageUrlTpye,
    ImageDataTpye,
    videoType,
} SaveTypes;

@implementation PHPhotoLibrary (CustomPhotoAlbum)

- (PHAssetCollection *)createNewAlbumCalled:(NSString *)albumName
{
    PHFetchResult<PHAssetCollection *> *collectionResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collectionResult) {
        if ([collection.localizedTitle isEqualToString:albumName]) {
            NSLog(@"相册存在：%@",albumName);
            return collection;
        }
    }

    __block NSString *collectionId = nil;
    NSError *error;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        collectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumName].placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    if (!error) {
        NSLog(@"相册创建成功：%@",albumName);
        return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[collectionId] options:nil].firstObject;
    }else{
        NSLog(@"相册创建失败 error：%@",error);
        return nil;
    }
}

- (void)saveImage:(UIImage *)image ToAlbum:(NSString *)albumName completion:(PHAssetLibraryWriteImageCompletionBlock)completion failure:(PHAssetLibraryAccessFailureBlock)failure
{
    [self saveObject:image WithType:ImageTpye ToAlbum:albumName completion:^(id callbackObject) {
        completion((PHAsset *)callbackObject);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)saveImageWithImageUrl:(NSURL *)imageUrl ToAlbum:(NSString *)albumName completion:(PHAssetLibraryWriteImageCompletionBlock)completion failure:(PHAssetLibraryAccessFailureBlock)failure
{
    [self saveObject:imageUrl WithType:ImageUrlTpye ToAlbum:albumName completion:^(id callbackObject) {
        completion((PHAsset *)callbackObject);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)saveVideoWithUrl:(NSURL *)videoUrl ToAlbum:(NSString *)albumName completion:(PHAssetLibraryWriteVideoCompletionBlock)completion failure:(PHAssetLibraryAccessFailureBlock)failure
{
    [self saveObject:videoUrl WithType:videoType ToAlbum:albumName completion:^(id callbackObject) {
        completion((NSURL *)callbackObject);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)saveImageData:(NSData *)imageData ToAlbum:(NSString *)albumName completion:(PHAssetLibraryWriteImageCompletionBlock)completion failure:(PHAssetLibraryAccessFailureBlock)failure
{
    [self saveObject:imageData WithType:ImageDataTpye ToAlbum:albumName completion:^(id callbackObject) {
        completion((PHAsset *)callbackObject);
    } failure:^(NSError *error) {
        failure(error);
    }];
}



- (void)saveObject:(id)object WithType:(SaveTypes)savetype ToAlbum:(NSString *)albumName completion:(void(^)(id callbackObject))completion failure:(void(^)(NSError *error))failure
{
    if (![self canAccessPhotoAlbum]) {
        // 提示用户开启允许访问相册的权限
    }else{
        __block NSString *assetId = nil;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            assetId = [self getLocalIdentifierBy:object WithType:savetype];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            NSLog(@"Finished updating asset. %@", (success ? @"Success." : error));
            if (error) {
                return;
            }
            PHAssetCollection *collection = [self createNewAlbumCalled:albumName];
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
                PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject;
                [request addAssets:@[asset]];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                NSLog(@"Finished updating asset. %@", (success ? @"Success." : error));
                if (success) {
                    if (savetype == ImageTpye || savetype == ImageUrlTpye || savetype == ImageDataTpye) {
                        completion([PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject);
                    }else{
                        [[PHImageManager defaultManager] requestAVAssetForVideo:[PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                            completion([(AVURLAsset *)asset URL]);
                        }];
                    }
                    return;
                }else{
                    failure(error);
                }
            }];
        }];
    }
}


- (NSString *)getLocalIdentifierBy:(id)object WithType:(SaveTypes)saveType                                      
{
    if (saveType == ImageTpye) {
        return [PHAssetCreationRequest creationRequestForAssetFromImage:(UIImage *)object].placeholderForCreatedAsset.localIdentifier;
    }else if (saveType == ImageUrlTpye){
        return [PHAssetCreationRequest creationRequestForAssetFromImageAtFileURL:(NSURL *)object].placeholderForCreatedAsset.localIdentifier;
    }else if (saveType == ImageDataTpye){
        PHAssetCreationRequest *creationRequest = [PHAssetCreationRequest creationRequestForAsset];
        [creationRequest addResourceWithType:PHAssetResourceTypePhoto data:(NSData *)object options:nil];
        return creationRequest.placeholderForCreatedAsset.localIdentifier;
    }else{
        return [PHAssetCreationRequest creationRequestForAssetFromVideoAtFileURL:(NSURL *)object].placeholderForCreatedAsset.localIdentifier;
    }
}

- (id)getCallBackObjectBy:(NSString *)assetId WithType:(SaveTypes)saveType
{
    if (saveType == ImageTpye || saveType == ImageUrlTpye || saveType == ImageDataTpye) {
        return [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject;
    }else{
        __block NSURL *url = nil;
        [[PHImageManager defaultManager] requestAVAssetForVideo:[PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            url = [(AVURLAsset *)asset URL];
        }];
        return url;
    }
}

- (void)loadImagesFromAlbum:(NSString *)albumName completion:(void (^)(NSMutableArray *images, NSError *error))completion
{
    if (![self canAccessPhotoAlbum]) {
        
    }else{
        PHFetchResult<PHAssetCollection *> *collectionResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        PHFetchOptions *fetchOptions = [PHFetchOptions new];
        fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        [collectionResult enumerateObjectsUsingBlock:^(PHAssetCollection * collection, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([collection.localizedTitle isEqualToString:albumName]) {
                PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];
                __block NSMutableArray *imagesArr = [[NSMutableArray alloc] init];
                [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    PHAsset *asset = (PHAsset *)obj;
                    PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
                    option.networkAccessAllowed = YES;
                    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
                        if (downloadFinined && result) {
                            [imagesArr addObject:result];
                            if (imagesArr.count == fetchResult.count) {
                                completion(imagesArr,nil);
                            }
                        }
                    }];
                }];
                *stop = YES;
                return;
            }
        }];
    }
}


//  判断授权状态
- (BOOL)canAccessPhotoAlbum
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        // User has not yet made a choice with regards to this application
        NSLog(@"用户还没有关于这个应用程序做出了选择");
        return YES;
    }else if (status == PHAuthorizationStatusRestricted){
        // This application is not authorized to access photo data.
        // The user cannot change this application’s status, possibly due to active restrictions
        //   such as parental controls being in place.
        NSLog(@"家长控制,不允许访问");
        return NO;
    }else if (status == PHAuthorizationStatusDenied){
        // User has explicitly denied this application access to photos data.
        NSLog(@"用户拒绝当前应用访问相册,我们需要提醒用户打开访问开关");
        return NO;
    }else if (status == PHAuthorizationStatusAuthorized){
        // User has authorized this application to access photos data.
        NSLog(@"用户允许当前应用访问相册");
        return YES;
    }else{
        return NO;
    }
}

@end
