/*
 Cordova Text-to-Speech Plugin
 https://github.com/vilic/cordova-plugin-tts
 
 by VILIC VANE
 https://github.com/vilic
 
 MIT License
 */

#import <Cordova/CDV.h>
#import <Cordova/CDVAvailability.h>
#import "CDVTTS.h"

@implementation CDVTTS

- (void)pluginInitialize {
    synthesizer = [AVSpeechSynthesizer new];
    synthesizer.delegate = self;
}

- (void)speechSynthesizer:(AVSpeechSynthesizer*)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance*)utterance {
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    if (lastCallbackId) {
        [self.commandDelegate sendPluginResult:result callbackId:lastCallbackId];
        lastCallbackId = nil;
    } else {
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        callbackId = nil;
    }
}

-(void)execCommandSafeOnThreadpool:(void (^)())block withCDVInvokedUrlCommand:(CDVInvokedUrlCommand*)callbackContext {
    [self.commandDelegate runInBackground:^{
        @try {
            block();
        } @catch (NSException *exception) {
            [self error:exception withCDVInvokedUrlCommand:callbackContext];
        }
    }];
}

-(void)error:(NSException*)exception withCDVInvokedUrlCommand:(CDVInvokedUrlCommand*)context {
    NSLog(@"intellierror %@ %@", [exception reason], [exception callStackSymbols]);
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] callbackId:context.callbackId];
}

- (void)speak:(CDVInvokedUrlCommand*)command {
    [self execCommandSafeOnThreadpool:^{
        if (callbackId) {
            lastCallbackId = callbackId;
        }
        
        callbackId = command.callbackId;
        
        [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        
        NSDictionary* options = [command.arguments objectAtIndex:0];
        
        NSString* text = [options objectForKey:@"text"];
        NSString* locale = [options objectForKey:@"locale"];
        double rate = [[options objectForKey:@"rate"] doubleValue];
        
        if (!locale || (id)locale == [NSNull null]) {
            locale = @"en-US";
        }
        
        if (!rate) {
            rate = AVSpeechUtteranceDefaultSpeechRate;
        }
        
        if (text) {
            AVSpeechUtterance* utterance = [[AVSpeechUtterance new] initWithString:text];
            utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:locale];
            // Rate expression adjusted manually for a closer match to other platform.
            //utterance.rate = (AVSpeechUtteranceMinimumSpeechRate * 1.5 + AVSpeechUtteranceDefaultSpeechRate) / 2.25 * rate * rate;
            // workaround for https://github.com/vilic/cordova-plugin-tts/issues/21
            /*if ([[[UIDevice currentDevice] systemVersion] floatValue] <= 9.0) {
             utterance.rate = utterance.rate * 2;
             // see http://stackoverflow.com/questions/26097725/avspeechuterrance-speed-in-ios-8
             }*/
            //utterance.pitchMultiplier = 1.2;
            [synthesizer speakUtterance:utterance];
        } else {
            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:callbackId];
        }
    } withCDVInvokedUrlCommand:command];
    
}

- (void)stop:(CDVInvokedUrlCommand*)command {
    [synthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
}

- (void)checkLanguage:(CDVInvokedUrlCommand *)command {
    NSArray *voices = [AVSpeechSynthesisVoice speechVoices];
    NSString *languages = @"";
    for (id voiceName in voices) {
        languages = [languages stringByAppendingString:@","];
        languages = [languages stringByAppendingString:[voiceName valueForKey:@"language"]];
    }
    if ([languages hasPrefix:@","] && [languages length] > 1) {
        languages = [languages substringFromIndex:1];
    }
    
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:languages];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}
@end
