/*
 *  Copyright 2011 Martin Roth (mhroth@gmail.com)
 *
 *  This file is part of FrogDisco.
 *
 *  FrogDisco is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  FrogDisco is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with FrogDisco.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>
#import <Foundation/Foundation.h>

#import "com_synthbot_frogdisco_FrogDisco.h"

typedef enum SampleFormat {
  INTERLEAVED_SHORT,
  UNINTERLEAVED_FLOAT
} SampleFormat;

// http://developer.apple.com/library/mac/#documentation/MusicAudio/Conceptual/AudioQueueProgrammingGuide/Introduction/Introduction.html
// http://developer.apple.com/library/mac/#documentation/MusicAudio/Reference/AudioQueueReference/Reference/reference.html
@interface FrogAudio : NSObject {
  AudioQueueRef outAQ;
  NSUInteger numInputChannels;
  NSUInteger numOutputChannels;
  NSUInteger blockSize;
  Float64 sampleRate;
  SampleFormat sampleFormat;
  jobject directByteBuffer;
  jobject frogDisco; // the associated java object
  jmethodID mID_shortCallback;
  jmethodID mID_floatCallback;
}

- (id)initWithInputChannels:(NSUInteger)inputChannels outputChannels:(NSUInteger)outputChannels
    blockSize:(NSUInteger)framesPerBlock sampleRate:(Float64)sampleRate
    sampleFormat:(SampleFormat)sampleFormat numAudioBuffers:(NSUInteger)numAudioBuffers
    javaObject:(jobject)jobj andEnv:(JNIEnv *)env;

- (void)play;
- (void)pause;

- (void)renderCallback:(AudioQueueBufferRef)inBuffer withEnv:(JNIEnv *)env;

/* Should be called right before dealloc. */
- (void)deallocJavaObjects:(JNIEnv *)env;

@end
