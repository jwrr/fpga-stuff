conv2d
======

This block performs a 2d convolution on streaming video. The kernel size and frame size can be configured with
generics.

Status
------
Far from done. Most blocks are tbd.

Simulation
----------
* Simulations use [GHDL](http://ghdl.free.fr/) [github](https://github.com/ghdl/ghdl).
* The waveform viewer is [GTLWave](http://gtkwave.sourceforge.net/) [github](https://github.com/gtkwave/gtkwave).
* Each major block has a testbench.

```
  CLEAN
  
  RUN filelists/dpram.filelist
  RUN filelists/video_line_buffer.filelist

  VIEW_WAVES
```

Design Hierarchy
----------------

* conv2d
  * video_line_buffer
    * dpram - Dual Port Ram (one instance for each line)
  * video_window
  * kernel
  * mat_mult


