# Floral-Automata

Processing code (with easily accessible parameter configuration) to generate mandalas from circularly arranged cellular automaton "tapes" (or "floral automata", as I like to call them).

![Screenshot BW](/screenshot-BW.png)

The backbone of this sketch is the insight of drawing the automaton's tape in a circle to reflect the nature of its "loop" topology, in which the last grid element is left-adjacent to the first one. The grid is then homogeneously initialized with the same symbol, except for 8 equally spaced points which carry a different one. This ascribes a 8-fold symmetry to the cellular automaton's dynamics, which can be observed in the "mandalas" it generates.

![Screenshot HSB](/screenshot-HSB.png)

Perhaps most interesting is the insight of "coarse-graining" the automaton's dynamics. It works the following way: first we apply a blurring filter (in our case a Gaussian blur) to even out chaotic regions of the automaton's dynamics; then we apply a K-level thresholding (implemented by Processing "posterize" filter) to cluster the image into K classes. Each of these classes can be thought of as a macroscopic view of the automaton's dynamics. For example, in the case of a simple automaton with 2 symbols (represented by 0 and 1), a 3-level thresholding has the effect of clustering the grid into "probably 0", "probably 1" and "random" regions, which correspond to black, white and gray respectively after the posterize filter is applied. Random regions, which have intrincate microscopic structures, are essentially homogeneous "gray" blobs for a macroscopic observer. Thus this method allows one to distinguish between chaotic and orderly behavior in cellular automata, and the resulting images are as beautiful as the correspoding dynamics are complex - remember, the science of complex systems teaches us that complexity is a mixture of order and chaos.
