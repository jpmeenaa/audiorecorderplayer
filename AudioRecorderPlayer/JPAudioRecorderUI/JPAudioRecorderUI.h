//
//  JPAudioRecorderUI.h
//  AudioRecorderPlayer
//
//  Created by JPMEENAA on 10/12/17.
//  Copyright © 2017 JPMEENAA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol JPAudioRecorderUIDelegate <NSObject>
/*
 *  Mathod For convert in data
 */
- (void)endConvertWithData:(NSData *)voiceData;

@end

@interface JPAudioRecorderUI : NSObject

@property (nonatomic, strong) UIViewController *controller;

@property (nonatomic, weak) id<JPAudioRecorderUIDelegate> delegate;

- (id)initWithDelegate:(id<JPAudioRecorderUIDelegate>)delegate;

+(JPAudioRecorderUI *)sharedInstance;
/*
 *  For Showing Recorder UI
 */
-(void)showRecorderOnView :(UIView *)baseView;
/*
 *  For Play Audio file
 */
-(void)playWithUrl:(NSURL *)url_file path:(NSString *)str_path;
/*
 *  For Stop Audio player
 */
-(void)stop;
/*
 *  For Check audio path in NSDocumentDirectory
 */
-(BOOL )isPathFound :(NSString *)str_imagePath;

@end
