# mark-duration
## Prerequisite
### MatLab
+ MatLab2019b or later
+ Image Processing Toolbox
### Python
+ pandas
+ tgt
## Usage
The `mark_closure` function is meant to mark the closure or/and release point of the tongue from M mode ultrasound images. The arguments include:
+ inputVideo: A .mp4 file that contains M mode ultrasound images.
+ inputcsv: A .csv file that contains at least two columns named 'Time' and 'Label'. The numbers in 'Time' column are assumed closure points.
+ delay: A number that is added to the assumed closure points.
+ start: a number that specify the n-th token and onwards. If not specified, the default is 1.
+ release: If false (default), for each time point, it only record the closure point. If true, it recorded both closure and release points.
