# ffmpeg-camera-effects

ffmpeg camera effects fun without opencv.
You can use effects as a source for videoconferencing applications.

Edit script to set up proper input and output video devices.

Tested on Ubuntu.

Inspired by https://oioiiooixiii.blogspot.com/2016/09/ffmpeg-extract-foreground-moving.html

## Prerequisites

You need to install ffmpeg and v4l2loopback kernel module

## Installing

Run following commands:

```
apt-get install ffmpeg v4l2loopback-dkms
```

## Running

To run a script type following command:

```
./cam-fun.sh
```

## Testing

If your output video device is /dev/video2 you can test it with one of following commands:

```
ffplay -f v4l2 /dev/video2
mpv --demuxer-lavf-format v4l2 /dev/video2
```

## Authors

* **Silvije2** [Github](https://github.com/silvije2/)

## License

GPL-3.0-or-later

