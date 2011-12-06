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

package com.synthbot.frogdisco;

public class FrogDisco {
  
  private final long nativePtr;
  private final CoreAudioRenderListener listener;
  
  /**
   * 
   * @param numOutputChannels
   * @param blockSize
   * @param sampleRate
   * @param sampleFormat
   * @param listener
   */
  public FrogDisco(int numOutputChannels, int blockSize, float sampleRate, SampleFormat sampleFormat,
      CoreAudioRenderListener listener) {
    this.listener = listener;
    nativePtr = initCoreAudio(sampleFormat.ordinal());
  }
  
  private native long initCoreAudio(int sampleFormat);
  
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
  
  private void onCoreAudioShortRenderCallback(short[] buffer) {
    listener.onCoreAudioShortRenderCallback(buffer);
  }
  
  private void onCoreAudioFloatRenderCallback(float[] buffer) {
    listener.onCoreAudioFloatRenderCallback(buffer);
  }

}
