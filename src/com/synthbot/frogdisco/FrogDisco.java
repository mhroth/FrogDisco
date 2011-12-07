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

package com.synthbot.frogdisco;

import java.nio.ByteBuffer;

public class FrogDisco {
  
  private final long nativePtr;
  private final CoreAudioRenderListener listener;
  private final SampleFormat sampleFormat;
  private final int numOutputChannels;
  private final int blockSize;
  private double sampleRate;
  
  /**
   * <code>FrogDisco</code> provides an interface to Core Audio from Java. Note that when instantiating
   * an instance of <code>FrodDisco</code> it may make several calls to the <code>CoreAudioRenderListener</code>
   * in order to prebuffer the underlying <code>AudioQueue</code>s.
   * Multiple instances of <code>FrogDisco</code> may exist independently, with varying parameters.
   * Core Audio will automatically mix them together, though there can be a performance penalty.
   * @param numOutputChannels The number of output channels. Usually 1 or 2. Must be positive.
   * @param blockSize  The number of samples per channel. Must be a power of two, at least 128.
   * @param sampleRate  The number of audio samples processed per second per channel. Must be either
   * 22050.0 or 44100.0.
   * @param sampleFormat  The sample format. Either <code>SampleFormat.INTERLEAVED_SHORT</code> or
   * <code>SampleFormat.UNINTERLEAVED_FLOAT</code>.
   * @param listener  The <code>CoreAudioRenderListener</code> which will receive render callbacks
   * to process the audio buffers.
   */
  public FrogDisco(int numOutputChannels, int blockSize, double sampleRate, SampleFormat sampleFormat,
      CoreAudioRenderListener listener) {
    if (numOutputChannels <= 0) {
      throw new IllegalArgumentException("numOutputChannels must be positive.");
    }
    if (blockSize <= 0) {
      // TODO(mhroth): block size must be a power of two
      throw new IllegalArgumentException("blockSize must be positive.");
    }
    if (!(sampleRate == 22050.0 || sampleRate == 44100.0)) {
      // this is an arbitrary restriction, but these sample rates are definitely supported
      throw new IllegalArgumentException("Only sample rates of 22050Hz and 44100Hz are currently supported.");
    }
    if (sampleFormat == null) {
      throw new NullPointerException("Sample format may not be null.");
    }
    if (listener == null) {
      throw new NullPointerException("CoreAudioRenderListener may not be null.");
    }
    
    this.numOutputChannels = numOutputChannels;
    this.blockSize = blockSize;
    this.sampleRate = sampleRate;
    this.sampleFormat = sampleFormat;
    this.listener = listener;
    nativePtr = initCoreAudio(0, numOutputChannels, blockSize, sampleRate, sampleFormat.ordinal());
  }
  
  private native long initCoreAudio(int numInputChannels, int numOutputChannels, int blockSize,
      double sampleRate, int sampleFormat);
  
  static {
    System.loadLibrary("FrogDisco");
  }
  
  /**
   * Automatically unloads the native component if not already done.
   */
  @Override
  protected synchronized void finalize() throws Throwable {
    try {
      deallocCoreAudio(nativePtr);
    } finally {
      super.finalize();
    }
  }
  
  private native void deallocCoreAudio(long ptr);
  
  /**
   * Start or resume playback. The render callback is executed.
   */
  public void play() {
    play(nativePtr);
  }
  
  private native void play(long ptr);
  
  /**
   * Pauses playback. The render callback is no longer executed.
   */
  public void pause() {
    pause(nativePtr);
  }

  private native void pause(long ptr);

  public int getNumOutputChannels() {
    return numOutputChannels;
  }

  public int getBlockSize() {
    return blockSize;
  }

  public double getSampleRate() {
    return sampleRate;
  }

  public SampleFormat getSampleFormat() {
    return sampleFormat;
  }

  @Override
  public String toString() {
    return super.toString() + " channels:" + numOutputChannels + " blockSize:" + blockSize +
        " sampleRate:" + sampleRate + " sampleFormat:" + sampleFormat.name();
  }

  private void onCoreAudioShortRenderCallback(ByteBuffer buffer) {
    listener.onCoreAudioShortRenderCallback(buffer.asShortBuffer());
  }

  private void onCoreAudioFloatRenderCallback(ByteBuffer buffer) {
    listener.onCoreAudioFloatRenderCallback(buffer.asFloatBuffer());
  }
}
