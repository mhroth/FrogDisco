package com.synthbot.frogdisco;

import java.nio.ByteOrder;
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
