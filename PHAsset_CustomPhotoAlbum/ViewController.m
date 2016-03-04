//
//  ViewController.m
//  PHAsset_CustomPhotoAlbum
//
//  Created by jiangxk on 16/3/3.
//  Copyright © 2016年 蒋先科. All rights reserved.
//

#import "ViewController.h"
#import "PHPhotoLibrary+CustomPhotoAlbum.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //    [[PHPhotoLibrary sharedPhotoLibrary] createNewAlbumCalled:@"ios9新相册"];
#if 1
    [[PHPhotoLibrary sharedPhotoLibrary] saveImage:[UIImage imageNamed:@"猫猫.jpg"] ToAlbum:@"新相册" completion:^(PHAsset *imageAsset) {
        NSLog(@"%@",imageAsset);
    } failure:^(NSError *error) {
    }];
#endif
    
#if 0
    [[PHPhotoLibrary sharedPhotoLibrary] saveImageWithImageUrl:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"猫猫" ofType:@"jpg"]] ToAlbum:@"ios9新相册" completion:^(PHAsset *imageAsset) {
        NSLog(@"%@",imageAsset);
    } failure:^(NSError *error) {
        
    }];
#endif
    
#if 0
    [[PHPhotoLibrary sharedPhotoLibrary] saveImageData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"猫猫" ofType:@"jpg"]] ToAlbum:@"ios9新相册1" completion:^(PHAsset *imageAsset){
        NSLog(@"%@",imageAsset);
    } failure:^(NSError *error) {
        
    }];
#endif
    
    
#if 0
    [[PHPhotoLibrary sharedPhotoLibrary] saveVideoWithUrl:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"bug" ofType:@"mov"]] ToAlbum:@"视频相册2" completion:^(NSURL *videoUrl) {
        
    } failure:^(NSError *error) {
        
    }];
#endif
    
    
#if 0
    [[PHPhotoLibrary sharedPhotoLibrary] loadImagesFromAlbum:@"新相册" completion:^(NSMutableArray *images, NSError *error) {
        NSLog(@"%@",images);
    }];
#endif
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
