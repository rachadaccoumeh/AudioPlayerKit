#ifdef __OBJC__
#import <UIKit/UIKit.h>
#include "../BASS/bass.h"
#import "../BASS/bass_fx.h"
#import "../BASS/bassopus.h"
#import "../BASS/bassflac.h"
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif


FOUNDATION_EXPORT double AudioPlayerKitVersionNumber;
FOUNDATION_EXPORT const unsigned char AudioPlayerKitVersionString[];

