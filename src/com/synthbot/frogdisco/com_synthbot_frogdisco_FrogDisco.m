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

#import "com_synthbot_frogdisco_FrogDisco.h"
#import "FrogAudio.h"

JavaVM *FrogAudio_globalJvm;

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *jvm, void *reserved) {
  // require JNI_VERSION_1_4 for access to NIO functions
  // http://docs.oracle.com/javase/1.4.2/docs/guide/jni/jni-14.html
  FrogAudio_globalJvm = jvm; // store the JVM so that it can be used to attach ASIO threads to the JVM during callbacks
  return JNI_VERSION_1_4;
}

JNIEXPORT jlong JNICALL Java_com_synthbot_frogdisco_FrogDisco_initCoreAudio
    (JNIEnv *env, jobject jobj, jint numInputChannels, jint numOutputChannels, jint blockSize,
    jdouble sampleRate, jint sampleFormat, jint numAudioBuffers) {
  FrogAudio *frogAudio = nil;
  @autoreleasepool {
    frogAudio = [[FrogAudio alloc]
        initWithInputChannels:numInputChannels outputChannels:numOutputChannels blockSize:blockSize
        sampleRate:sampleRate sampleFormat:sampleFormat numAudioBuffers:numAudioBuffers
        javaObject:jobj andEnv:env];
  }
  return (jlong) frogAudio;
}

JNIEXPORT void JNICALL Java_com_synthbot_frogdisco_FrogDisco_deallocCoreAudio
    (JNIEnv *env, jobject jobj, jlong nativePtr) {
  FrogAudio *frogAudio = (FrogAudio *) nativePtr;
  [frogAudio pause]; // just to be sure
  [frogAudio deallocJavaObjects:env];
  @autoreleasepool {
    [frogAudio release];
  }
}

JNIEXPORT void JNICALL Java_com_synthbot_frogdisco_FrogDisco_play
    (JNIEnv * env, jobject jobj, jlong nativePtr) {
  FrogAudio *frogAudio = (FrogAudio *) nativePtr;
  [frogAudio play];
}

JNIEXPORT void JNICALL Java_com_synthbot_frogdisco_FrogDisco_pause
    (JNIEnv * env, jobject jobj, jlong nativePtr) {
  FrogAudio *frogAudio = (FrogAudio *) nativePtr;
  [frogAudio pause];
}
