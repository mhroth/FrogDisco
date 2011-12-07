# FrogDisco

FrogDisco (FD) is a low latency OS X Core Audio wrapper for Java. The Java Sound API is notoriously slow, and this wrapper allows simple and fast (~3ms) access via Java [ByteBuffers](http://docs.oracle.com/javase/1.4.2/docs/api/java/nio/ByteBuffer.html) to an underlying [AudioQueue](http://developer.apple.com/library/mac/#documentation/MusicAudio/Conceptual/AudioQueueProgrammingGuide/Introduction/Introduction.html) service. FrogDisco supports interleaved short and uninterleaved float sample buffers, providing maximum application flexibility to the user. Multiple FrogDisco objects with varying paramters may be instantiated if necessary, and Core Audio will automatically take care of mixing the output. Currently only output is supported; line-in or microphone input is not yet supported.

The original use case of FD is to be able to create single JAR application based on Processing and Pd, without the added complexity of starting a JACK server. But ultimately FD allows any Java application access to low latency audio with a quick and easy API.

FrogDisco is similar in function to [JAsioHost](https://github.com/mhroth/jasiohost) available for Windows.

## Getting Started

FrogDisco comes in two parts, [FrogDisco.jar](https://github.com/mhroth/FrogDisco/blob/master/FrogDisco.jar) and [libFrogDisco.dylib](https://github.com/mhroth/FrogDisco/blob/master/libFrogDisco.dylib). The former is the usual encapsulation of the classes comprising the FD Java library, and the latter is the JNI interface to Core Audio. The package of FD is `com.synthbot.frogdisco`.

The library can be quickly tested from the root directory of the project with `java -jar FrogDisco.jar -Djava.library.path=./`.

+ Include `FrogDisco.jar` in your Java project.
+ Make `libFrogDisco.dylib` available to your project. This can be done in several ways:
  + Move or copy the library to `/Library/Java/Extensions`. This is the default search location for JNI libraries.
  + Inform the JVM where the library is located. This can be done with, e.g. `java -Djava.library.path=/Library/Java/Extensions`

If the JVM cannot find the dylib, an [UnsatisfiedLinkError](http://docs.oracle.com/javase/1.4.2/docs/api/java/lang/UnsatisfiedLinkError.html) exception will be thrown.

## Example

Below are the contents of [ExampleFrogDisco.java](https://github.com/mhroth/FrogDisco/blob/master/src/com/synthbot/frogdisco/ExampleFrogDisco.java) which shows how to use the FD API (it's really simple!). The example instantiates an instance of FrogDisco and registers itself as the `CoreAudioRenderListener`. FD is created with one output channel, a block size of 128 samples per channel per block, and a sample rate of 44100. `ExampleFrogDisco` implements one of the two callback functions, in this case `onCoreAudioFloatRenderCallback` because the sample format `UNINTERLEAVED_FLOAT` is specified. Whenever Core Audio needs more samples, the render callback is called and the listener must fill the `ByteBuffer`, or in this case a `FloatBuffer`.

```Java
package com.synthbot.frogdisco;

import java.nio.FloatBuffer;

public class ExampleFrogDisco extends CoreAudioRenderAdapter {

  private long sampleIndex = 0;
  private FrogDisco frogDisco;
  
  public ExampleFrogDisco() {
    frogDisco = new FrogDisco(1, 128, 44100.0, SampleFormat.UNINTERLEAVED_FLOAT, this);
  }
  
  public void play() {
    frogDisco.play();
  }
  
  @Override
  public void onCoreAudioFloatRenderCallback(FloatBuffer buffer) {
    int length = buffer.capacity();
    for (int i = 0; i < length; i++, sampleIndex++) {
      buffer.put((float) Math.sin(2.0 * Math.PI * 440.0 * sampleIndex / 44100.0));
    }
  }

  public static void main(String[] args) {
    ExampleFrogDisco example = new ExampleFrogDisco();
    example.play();
    try {
      Thread.sleep(2000);
    } catch (InterruptedException e) {
      e.printStackTrace();
    }
    System.out.println("ExampleFrogDisco exiting.");
  }
}
```

## License

FrogDisco is licensed under the [LGPL](http://www.gnu.org/licenses/lgpl.html).