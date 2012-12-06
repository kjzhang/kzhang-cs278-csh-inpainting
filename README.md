### Kevin Zhang
CS278 Spring 2012

Inpainting program using the CSH algorithm from Korman, S., Avidan, S., "Coherency Sensitive Hashing," Computer Vision (ICCV), 2011 IEEE International Conference on , vol., no., pp.1607-1614, 6-13 Nov. 2011
doi: 10.1109/ICCV.2011.6126421. [Link](http://www.eng.tau.ac.il/~simonk/CSH/index.html)

Uses the CSH approximate nearest neighbor algorithm provided by the authors. [Link](http://www.eng.tau.ac.il/~simonk/CSH/index.html)

Requirements:

1. Matlab 2008 or later.
2. C/CPP compiler installed properly for mex compiling.


To install and run the CSH inpainting, please use the following instructions:

1. run AddPaths.
2. run compile_mex.
3. CSH_inpaint entry point function. CSH_level was an older version of the inpainting that doesn't work as well.
4. The GUI can be run from GUI.m. The GUI needs to be restarted after every run. Runs can be canceled with CTRL^C.
