# LightBluesky
<p align="center">
  <img alt="LightBluesky profile screenshot" src=".github/screenshots/profile.png" height="400" />
</p>

A Bluesky client made using Flutter, designed to be lightweight and easy to use.

**WIP**: For now, this project is very barebones, don't expect a full client.

## Installation
You will need flutter, it is tested for the `stable` version.

### Linux
You will need `libmpv` for handling video playback.

## Implemented
* Auth
  * 2FA
  * Different service
* Home
  * Timeline (Following)
  * Pinned feeds
* Search
  * Users
* Feeds
* Profile
  * Own
  * Others
* Posting
  * Reply to post
  * New post
  * Attach Media (images only)

## TODO
* Follow / unfollow
* Block / unblock
* Notifications
* Allow attaching video to post
* Allow swipe up to refresh list of items
* Add documentation
* Make tests
* Use SecureStorage for session data?

## Credits
This project wouldn't have been posible without the help of these third-party projects:
- [bluesky & bluesky_text](https://atprotodart.com/)
- [shared_preferences](https://github.com/flutter/packages/tree/main/packages/shared_preferences/shared_preferences)
- [url_launcher](https://github.com/flutter/packages/tree/main/packages/url_launcher/url_launcher)
- [dynamic_color](https://github.com/material-foundation/flutter-packages/tree/main/packages/dynamic_color)
- [video_player](https://github.com/flutter/packages/tree/main/packages/video_player/video_player)
- [media_kit & video_player_media_kit](https://github.com/media-kit/media-kit)
- [package_info_plus](https://github.com/fluttercommunity/plus_plugins)
- [file_picker](https://github.com/miguelpruivo/flutter_file_picker)
