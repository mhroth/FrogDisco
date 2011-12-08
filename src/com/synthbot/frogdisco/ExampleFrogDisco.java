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

import java.nio.FloatBuffer;
import java.nio.ShortBuffer;

public class ExampleFrogDisco extends CoreAudioRenderAdapter {

  private long sampleIndex = 0;
  private FrogDisco frogDisco;
  
  public ExampleFrogDisco() {
    frogDisco = new FrogDisco(1, 128, 44100.0, SampleFormat.UNINTERLEAVED_FLOAT, 4, this);
  }
  
  public void play() {
    frogDisco.play();
  }
  
  @Override
  public void onCoreAudioShortRenderCallback(ShortBuffer buffer) {
    int length = buffer.capacity();
    for (int i = 0; i < length; i++, sampleIndex++) {
      buffer.put((short) (32767.0 * Math.sin(2.0 * Math.PI * 440.0 * sampleIndex / 44100.0)));
    }
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
