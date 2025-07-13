# Across Time and Space
Computer Vision Challenge

## 1. Members of Group 15 (sorted by surname):
- Shuowen Li
- Bangdong Zhang
- Meng Zhang
- Yijing Zhang
- Yutian Zhang
- Junhan Zhu

## 2. Quick Start
- Run main.m to open the GUI, then press enter to startup
- Choose Folder: Default folder was './dataset'. press select -> Choose Folder to change it. Make sure that chosen folder are in following structure:

```
Chosen folder
│
├── sub_folder1
│   ├── image1.jpg
|   ├── image2.jpg
|   ├── :
│   └── imagen.jpg
│		:
└── sub_foldern
    ├── image1.jpg
    ├── image2.jpg
    ├── :
    └── imagen.jpg
```
- Visualization Methods: There are 3 different method to show the image matching results - Highlights, Difference Curtain and Time Lapse. Both highlights & difference curtain match 2 images. Time Lapse matches a series of images.
- **Image Selection**: Select image by clicking the image in the left file panel. Hold Ctrl and click to select multiple images. (**Note**: If you select more than 2 images for highlights & difference curtain, only the last chosen 2 images will be matched. It will also happen, if you select multiple images in highlights & difference curtain and then turn to time lapse.)
- Press 'match' to start matching
- Use slider in each visualization method to compare and make the difference more obviously.

## 3. Dependencies
- Computer Vision Toolbox
- Image Processing Toolbox
- Robotics System Toolbox
