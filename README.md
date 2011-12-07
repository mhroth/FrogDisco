# FrogDisco

FrogDisco (FD) is a low latency OS X Core Audio wrapper for Java. The Java Sound API is notoriously slow, and this wrapper allows simple and fast (~3ms) access via Java ByteBuffers to an underlying AudioQueue service. FrogDisco support interleaved short and uninterleaved float sample buffers, providing maximum application flexibility to the user. Multiple FrogDisco objects with varying paramters may be instantiated if necessary, and Core Audio will automatically take care of mixing the output. Currently only output is supported; line-in or microphone input is not yet supported.

FrogDisco is similar in function to [JAsioHost](https://github.com/mhroth/jasiohost) available for Windows.

## Getting Started

FrogDisco comes in two parts, a JAR and [libFrogDisco.dylib](https://github.com/mhroth/FrogDisco/blob/master/libFrogDisco.dylib). The former is the usual encapsulation of the classes comprising the FD library, and the latter is the JNI interface to Core Audio.

+ Include FrogDisco.jar in your Java project.
+ Make libFrogDisco.dylib available to your project. This can be done in several ways:
++ Move or copy the library to `/Library/Java/Extensions`. This is the default search location for JNI libraries
++ Inform the JVM where the library is located. This can be done with, e.g. `java -Djava.library.path=/Library/Java/Extensions`


### License

FrogDisco is licensed under the [LGPL](http://www.gnu.org/licenses/lgpl.html).