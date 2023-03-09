# vistrack_fast
Using the standard cell tracking pipeline from the Spencer Lab (not included in this repo), take binary mask files after track linking and perform visual verification of the tracking quality using vistrack_fast. This method writes a video file after tracking that colors the cells with a psuedo-random colormap to visualize track linking. This algorithm is an improvement upon our classic vistrack pipeline, which is orders of magnitude slower than this new method. This algorithm also writes a considerably smaller video file, so issues with buffering lag are resolved.

Example output video file: https://youtu.be/hX6CyEvNxss
