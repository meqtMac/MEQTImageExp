# MyImageIO

A Demo of Use MEQT to do some Image ralated works.


## Experimental Content
### Implementation of Motion Estimation

Implement motion vector calculation using Full Search and Three-Step Search algorithms
Matching criterion: SAD (Sum of Absolute Differences); Block size: 8*8, Search range: [-w, w], where w is a positive integer
Compare the computational complexity when different integer values of w are used (take three different values of w and calculate the number of searches and execution time)
Implementation of Motion Compensation

### Implement motion compensation using motion vectors and plot the residual image

### Experimental Principle
#### Motion Estimation:
In inter-frame predictive coding, there is a certain correlation between objects in adjacent frames of the moving image. Therefore, the moving image can be divided into several blocks or macroblocks, and an attempt is made to search for the position of each block or macroblock in the neighboring frame image and obtain the relative offset of the spatial position between them. The obtained relative offset is commonly referred to as the motion vector, and the process of obtaining the motion vector is called motion estimation.
The motion vectors and the prediction errors obtained after motion matching are sent to the decoding end. At the decoding end, the corresponding block or macroblock is found in the already decoded neighboring reference frame image, according to the position indicated by the motion vector. The block or macroblock is then added to the prediction error to obtain the position of the block or macroblock in the current frame.
Motion estimation can remove inter-frame redundancy, greatly reducing the number of bits transmitted in video transmission. Therefore, motion estimation is an important component of video compression processing systems.

#### Motion Compensation:
Motion compensation is a method of describing the differences between adjacent frames (where adjacency here means adjacent in terms of coding relationship, not necessarily in terms of playback order). Specifically, it describes how each small block in the previous frame moves to a certain position in the current frame. This method is often used by video compressors/video codecs to reduce spatial redundancy in video sequences. It can also be used for deinterlacing and motion interpolation operations.

## Experimental Results
Full Path
| Size | Count | Diff | Time |
|------|-------|------|------|
| 2    | 36975 | 1038889.0 | 0.088404708  |
| 4    | 119799 | 652558.0 | 0.2244735  |
| 5    | 178959 | 553845.0 | 0.317256333  |
| 6    | 249951 | 493995.0 | 0.429708458  |
| 7    | 332775 | 473335.0 | 0.5654635  |
| 8    | 426072 | 468228.0 | 0.723223583  |
| 9    | 529368 | 465525.0 | 0.903010417  |
| 10   | 643864 | 463729.0 | 1.073919  |
| 16   | 1563435 | 457799.0 | 2.572798291  |
| 24   | 3353760 | 452846.0 | 5.505978583  |
| 32   | 5738775 | 449463.0 | 9.388519334|

Three Step
| Size | Count | Diff | Time |
|------|-------|------|------|
| 2    | 26622 | 1064339.0 | 0.065214959  |
| 4    | 39933 | 797469.0 | 0.093250375  |
| 5    | 39933 | 743240.0 | 0.08832875  |
| 6    | 39933 | 674042.0 | 0.096404541  |
| 7    | 39933 | 713027.0 | 0.096697708  |
| 8    | 53005 | 721936.0 | 0.119951334  |
| 9    | 52768 | 747284.0 | 0.110444916  |
| 10   | 52768 | 720764.0 | 0.109107292  |
| 16   | 65605 | 715721.0 | 0.128684834  |
| 24   | 64904 | 659516.0 | 0.133906125  |
| 32   | 77285 | 711075.0 | 0.150394333  |
