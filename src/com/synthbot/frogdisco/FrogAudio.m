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
 *  JVstHost is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *  
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with FrogDisco.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#import <Accelerate/Accelerate.h>
#import "FrogAudio.h"

@implementation FrogAudio

extern JavaVM *FrogAudio_globalJvm;


#pragma mark - Miscellaneous

// set the endianness of the buffer by calling byteBuffer.order(ByteOrder.nativeOrder())
void setByteOrder(jobject byteBuffer, JNIEnv *env) {
  // set the endianness of the buffer by calling byteBuffer.order(ByteOrder.nativeOrder())
  jobject nativeOrder = (*env)->CallStaticObjectMethod(env, (*env)->FindClass(env, "java/nio/ByteOrder"),
      (*env)->GetStaticMethodID(env, (*env)->FindClass(env, "java/nio/ByteOrder"),
          "nativeOrder", "()Ljava/nio/ByteOrder;"));
  (*env)->CallObjectMethod(env, byteBuffer,
      (*env)->GetMethodID(env, (*env)->FindClass(env, "java/nio/ByteBuffer"),
          "order", "(Ljava/nio/ByteOrder;)Ljava/nio/ByteBuffer;"), nativeOrder);
}


#pragma mark - Render Callback

void renderCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer) {
  JNIEnv *env = nil;
  jint res = (*FrogAudio_globalJvm)->AttachCurrentThreadAsDaemon(FrogAudio_globalJvm, (void **) &env, NULL);
  if (res == JNI_OK) {
    FrogAudio *frogAudio = (FrogAudio *) inUserData;
    [frogAudio renderCallback:inBuffer withEnv:env];
  } else {
    memset(inBuffer->mAudioData, 0, inBuffer->mAudioDataBytesCapacity);
  }
  inBuffer->mAudioDataByteSize = inBuffer->mAudioDataBytesCapacity; // entire buffer is filled
  AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
}

- (void)renderCallback:(AudioQueueBufferRef)inBuffer withEnv:(JNIEnv *)env {
  // the buffer contains the input, and when libpd_process_float returns, it contains the output
  
  switch (sampleFormat) {
    case INTERLEAVED_SHORT: {
      // ensure that a ByteBuffer exists for the native audio buffer
      if (directByteBuffer == nil) {
        directByteBuffer = (*env)->NewDirectByteBuffer(env, inBuffer->mAudioData,
            inBuffer->mAudioDataBytesCapacity);
        directByteBuffer = (*env)->NewGlobalRef(env, directByteBuffer);
        setByteOrder(directByteBuffer, env);
      } else if ((*env)->GetDirectBufferAddress(env, directByteBuffer) != inBuffer->mAudioData) {
        // in case the native audio buffer has changed (possible but very unlikely)
        (*env)->DeleteGlobalRef(env, directByteBuffer);
        directByteBuffer = (*env)->NewDirectByteBuffer(env, inBuffer->mAudioData,
            inBuffer->mAudioDataBytesCapacity);
        directByteBuffer = (*env)->NewGlobalRef(env, directByteBuffer);
        setByteOrder(directByteBuffer, env);
      }
      
      // call to java to fill the short buffer
      (*env)->CallVoidMethod(env, frogDisco, mID_shortCallback, directByteBuffer);
      break;
    }
    case UNINTERLEAVED_FLOAT: {
      // call to java to fill the float buffer
      (*env)->CallVoidMethod(env, frogDisco, mID_floatCallback, directByteBuffer);
      
      float *foutputBuffers = (float *) (*env)->GetDirectBufferAddress(env, directByteBuffer);
      
      // clip output to [-1,1], just to be sure
      float min = -1.0f;
      float max = 1.0f;
      vDSP_vclip(foutputBuffers, 1, &min, &max, foutputBuffers, 1, numOutputChannels*blockSize);
      
      // scale the floating-point samples to short range
      float a = 32767.0f;
      vDSP_vsmul(foutputBuffers, 1, &a, foutputBuffers, 1, numOutputChannels*blockSize);
      
      short *shortBuffer = (short *) inBuffer->mAudioData;
      switch (numOutputChannels) {
        default: { // output channels > 2
          for (int i = 2; i < numOutputChannels; ++i) {
            vDSP_vfix16(foutputBuffers+i*blockSize, numOutputChannels, shortBuffer+i, 1, blockSize);
          } // allow fallthrough
        }
        case 2: vDSP_vfix16(foutputBuffers+blockSize, 1, shortBuffer+1, numOutputChannels, blockSize);
        case 1: vDSP_vfix16(foutputBuffers, 1, shortBuffer, numOutputChannels, blockSize);
        case 0: break;
      }
      break;
    }
    default: {
      // if the sample format is not recognised, clear the buffer
      memset(inBuffer->mAudioData, 0, inBuffer->mAudioDataBytesCapacity);
      break;
    }
  }
}


#pragma mark - PdAudio

#define NUM_AUDIO_BUFFERS 5
- (id)initWithInputChannels:(NSUInteger)inputChannels outputChannels:(NSUInteger)outputChannels
    blockSize:(NSUInteger)framesPerBlock sampleRate:(Float64)aSampleRate
    sampleFormat:(SampleFormat)aSampleFormat javaObject:(jobject)jobj andEnv:(JNIEnv *)env {
  self = [super init];
  if (self != nil) {
    numInputChannels = inputChannels;
    numOutputChannels = outputChannels;
    blockSize = framesPerBlock;
    sampleRate = aSampleRate;
    frogDisco = (*env)->NewWeakGlobalRef(env, jobj);
    switch (aSampleFormat) {
      default: // make sure that there is always a valid sample format
      case INTERLEAVED_SHORT: sampleFormat = INTERLEAVED_SHORT; break;
      case UNINTERLEAVED_FLOAT: sampleFormat = UNINTERLEAVED_FLOAT; break;
    }
    
    // configure the output audio format to standard 16-bit stereo
    AudioStreamBasicDescription outAsbd;
    outAsbd.mSampleRate = aSampleRate;
    outAsbd.mFormatID = kAudioFormatLinearPCM;
    outAsbd.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    outAsbd.mBytesPerPacket = (UInt32) (2*outputChannels);
    outAsbd.mFramesPerPacket = 1;
    outAsbd.mBytesPerFrame = (UInt32) (2*outputChannels);
    outAsbd.mChannelsPerFrame = (UInt32) outputChannels;
    outAsbd.mBitsPerChannel = 16;
    outAsbd.mReserved = 0;
    
    mID_shortCallback = (*env)->GetMethodID(env, 
        (*env)->FindClass(env, "com/synthbot/frogdisco/FrogDisco"), "onCoreAudioShortRenderCallback",
        "(Ljava/nio/ByteBuffer;)V");
    mID_floatCallback = (*env)->GetMethodID(env, 
        (*env)->FindClass(env, "com/synthbot/frogdisco/FrogDisco"), "onCoreAudioFloatRenderCallback",
        "(Ljava/nio/ByteBuffer;)V");
    
    directByteBuffer = nil;
    if (sampleFormat == UNINTERLEAVED_FLOAT) {
      float *buffer = (float *) calloc(outputChannels*blockSize, sizeof(float));
      directByteBuffer = (*env)->NewDirectByteBuffer(env, buffer, outputChannels*blockSize*sizeof(float));
      directByteBuffer = (*env)->NewGlobalRef(env, directByteBuffer);
      setByteOrder(directByteBuffer, env);
    }
    
    // create the new audio buffer
    // http://developer.apple.com/library/mac/#documentation/MusicAudio/Reference/AudioQueueReference/Reference/reference.html
    OSStatus err = AudioQueueNewOutput(&outAsbd, renderCallback, self, NULL, kCFRunLoopCommonModes, 0, &outAQ);
    AudioQueueSetParameter(outAQ, kAudioQueueParam_Volume, 1.0f);
    
    // create three audio buffers to go into the new queue and initialise them
    AudioQueueBufferRef outBuffer;
    for (int i = 0; i < NUM_AUDIO_BUFFERS; i++) {
      err = AudioQueueAllocateBuffer(outAQ, outAsbd.mBytesPerFrame*(UInt32)blockSize, &outBuffer);
      renderCallback(self, outAQ, outBuffer);
    }
    
    err = AudioQueuePrime(outAQ, 0, NULL);
  }
  return self;
}

- (void)deallocJavaObjects:(JNIEnv *)env {
  (*env)->DeleteWeakGlobalRef(env, frogDisco);
  if (sampleFormat == UNINTERLEAVED_FLOAT) {
    float *buffer = (*env)->GetDirectBufferAddress(env, directByteBuffer);
    free(buffer);
  }
  (*env)->DeleteGlobalRef(env, directByteBuffer);
}

- (void)dealloc {
  AudioQueueStop(outAQ, YES);
  AudioQueueDispose(outAQ, YES);
  [super dealloc];
}

- (void)play {
  AudioQueueStart(outAQ, NULL);
}

- (void)pause {
  AudioQueuePause(outAQ);
}


@end
