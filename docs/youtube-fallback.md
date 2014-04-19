# Video Fallback Player

Certain schools block [youtube.com](http://youtube.com) and [youtubeeducation.com](http://youtubeeducation.com), where our videos are hosted.

As a fallback, we display the downloadable copy of our videos using video.js.

# Detecting missing video

We use the technique from Khan Academy's [YouTube fallback](http://code.google.com/p/khanacademy/issues/detail?id=13721), testing `img` loading of `youtube.com/favicon.ico`.

Youtube.com does not currently have a favicon.ico.

# Video.js

To display our videos, we use video.js with files served from our server through the Rails asset pipeline. This includes files in `vendor/assets/[fonts, javascripts, stylesheets, flash]`.

# Manually testing YouTube blocked behavior

## Fake-blocking YouTube

```
sudo vim /etc/hosts
# insert:
127.0.0.1       www.youtube.com
127.0.0.1       youtube.com
127.0.0.1       youtubeeducation.com
127.0.0.1       www.youtubeeducation.com
127.0.0.1       ytimg.com
```

## Firefox: Fake-blocking Flash

Firefox does not support HTML5 video playing of mp4 video files, so we want to consider the cases of:

1. Firefox visitors with Flash player
2. Firefox visitors without Flash player

To test how the page looks with Firefox without Flash, use the [FlashDisable](https://addons.mozilla.org/en-US/firefox/addon/flashdisable/) Firefox extension.

## Resetting session to show videos

Hit the local endpoint [http://localhost:3000/reset_session](http://localhost:3000/reset_session) to reset your session and the video will show again.

## On BrowserStack Live

Using [BrowserStack Live](http://www.browserstack.com/start), click to begin local testing. Enter the following parameters:

![](http://i.imgur.com/mzocimK.png)

*After* starting the local tunnel, follow the instructions for fake-blocking YouTube in your `/etc/hosts` above as well. This must be done *after* connecting to BrowserStack to avoid BrowserStack's tunnel host connection checker.
