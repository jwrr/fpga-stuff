pwm
===

* Open vitis_hls
* Create new project called pwm-hls
* Add source files and testbench files
* Run C Simulation
* Set pwm to be the Top Function
  * Project -> Project Settings -> Synthesis -> Top Function
* Run C Synthesis
* View Schedule Viewer Report
  * C SYNTHESIS -> Reports & Viewers -> Schedule Viewer
  * It should complete in one step (step 0)
* Run Cosimulation
  * Set "Dump Trace" to "all"
* Open Wave Viewer
  * Drag signal "o_pulse" into the waveform window
* Export RTL
  * The defaults are fine. Clock "OK"
* Open Vivado
* Create Project called pwm-rtl
* Create Block Design
* Add IP Repository that was exported from vitis_hls
  * Right-click on the Diagram area -> IP Settings -> IP -> Repository -> + IP Repositories
  * Browse to and select the newly created "pwm-hls" folder
* Add IP block "pwm" to the diagram
  * Right-click on the Diagram area -> Add IP -> Search "pwm" -> select
* Connect IO Ports
  * Make External "ap_clk" and rename to "clk"
    * Right-click on block port -> Make External
	* Rename using "Block pin properties window" which should be open.
  * Make External "i_hi[7:0]" and rename to "sw[7:0]"
  * Make External "o_pulse" and rename to "led_0"
* Create HDL Wrapper
  * Block Design -> Sources -> Design Sources
  * Right-click on "pwm" -> Create HDL Wrapper

  


