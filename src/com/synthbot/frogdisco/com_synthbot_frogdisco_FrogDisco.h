/* DO NOT EDIT THIS FILE - it is machine generated */
#include <JavaVM/jni.h>
/* Header for class com_synthbot_frogdisco_FrogDisco */

#ifndef _Included_com_synthbot_frogdisco_FrogDisco
#define _Included_com_synthbot_frogdisco_FrogDisco
#ifdef __cplusplus
extern "C" {
#endif
/*
 * Class:     com_synthbot_frogdisco_FrogDisco
 * Method:    initCoreAudio
 * Signature: (IIIDI)J
 */
JNIEXPORT jlong JNICALL Java_com_synthbot_frogdisco_FrogDisco_initCoreAudio
  (JNIEnv *, jobject, jint, jint, jint, jdouble, jint);

/*
 * Class:     com_synthbot_frogdisco_FrogDisco
 * Method:    deallocCoreAudio
 * Signature: (J)V
 */
JNIEXPORT void JNICALL Java_com_synthbot_frogdisco_FrogDisco_deallocCoreAudio
  (JNIEnv *, jobject, jlong);

/*
 * Class:     com_synthbot_frogdisco_FrogDisco
 * Method:    play
 * Signature: (J)V
 */
JNIEXPORT void JNICALL Java_com_synthbot_frogdisco_FrogDisco_play
  (JNIEnv *, jobject, jlong);

/*
 * Class:     com_synthbot_frogdisco_FrogDisco
 * Method:    pause
 * Signature: (J)V
 */
JNIEXPORT void JNICALL Java_com_synthbot_frogdisco_FrogDisco_pause
  (JNIEnv *, jobject, jlong);

#ifdef __cplusplus
}
#endif
#endif
