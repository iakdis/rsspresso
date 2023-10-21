
<p>
  <a href="https://github.com/iakmds/rsspresso/releases/latest" alt="Release">
  <img src="https://img.shields.io/github/v/release/iakmds/rsspresso?style=flat-square" /></a>

  <a href="https://github.com/iakmds/rsspresso/issues" alt="Issues">
  <img src="https://img.shields.io/github/issues/iakmds/rsspresso?style=flat-square" /></a>

  <a href="https://github.com/iakmds/rsspresso/pulls" alt="Pull requests">
  <img src="https://img.shields.io/github/issues-pr/iakmds/rsspresso?style=flat-square" /></a>

  <a href="https://github.com/iakmds/rsspresso/contributors" alt="Contributors">
  <img src="https://img.shields.io/github/contributors/iakmds/rsspresso?style=flat-square" /></a>

  <a href="https://github.com/iakmds/rsspresso/network/members" alt="Forks">
  <img src="https://img.shields.io/github/forks/iakmds/rsspresso?style=flat-square" /></a>

  <a href="https://github.com/iakmds/rsspresso/stargazers" alt="Stars">
  <img src="https://img.shields.io/github/stars/iakmds/rsspresso?style=flat-square" /></a>

  <a href="https://github.com/iakmds/rsspresso/blob/master/LICENSE" alt="License">
  <img src="https://img.shields.io/github/license/iakmds/rsspresso?style=flat-square" /></a>
</p>

<br>

<p align="center">
  <a href="https://github.com/iakmds/rsspresso">
    <img src="https://github.com/iakmds/rsspresso/blob/master/.github/icon.svg" alt="rssPresso app icon" width="200">
  </a>
</p>

<h1 align="center">rssPresso - The RSS reader with coffee</h1>
<p align="center">A minimal, cross-platform news aggregator written in Flutter. Available on Android, Windows and Linux.</p>

<details open="open">
  <summary><h2 style="display: inline-block">Table of Contents</h2></summary>
  <ol>
    <li>
      <a href="#what-is-rsspresso">What is rssPresso?</a>
      <ul>
        <li><a href="#screenshots">Screenshots</a></li>
        <li><a href="#features">Features</a></li>
      </ul>
    </li>
    <li>
      <a href="#downloads">Downloads</a>
      <ul>
        <li><a href="#android">Android</a></li>
        <li><a href="#windows">Windows</a></li>
        <li><a href="#macos">macOS</a></li>
        <li><a href="#linux">Linux</a></li>
      </ul>
    </li>
    <li>
      <a href="#contributing">Contributing</a>
      <ul>
          <li><a href="#code">Code</a></li>
          <li><a href="#bug-reports-feature-requests-and-improvements">Bug reports, feature requests and improvements</a></li>
      </ul>
    </li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#packages-used">Packages used</a></li>
    <li><a href="#credits">Credits</a></li>
    <li><a href="#license">License</a></li>
  </ol>
</details>

# What is rssPresso?

rssPresso is a **minimal**, **cross-platform** **news aggregator** written in Flutter. 

Import your favorite **RSS/Atom** feeds and start reading ahead. Load the full content of an article with a click of a button, or open it externally. You can star your article for later - and, when you're ready, simply filter your feed by saved or unread articles. Easily search your feeds to find what you want. Switch between different UI layouts to suit your needs. Enjoy a modern Material design with a light & dark theme. <a href="LICENSE">Free and open source</a> - for your freedom.

# Screenshots
<p float="left">
  <img src="https://github.com/iakmds/rsspresso/blob/master/.github/desktop-light-article.png" alt="Desktop screenshot light article">
  <img src="https://github.com/iakmds/rsspresso/blob/master/.github/desktop-dark-article.png" alt="Desktop screenshot dark article">
</p>

# Downloads

- Currently supported platforms: Android, Windows, Linux
- Planned: macOS (Unfortunately I do not currently own a macOS device; to build and test rssPresso, a macOS device is needed)

### Android

Download and install the [rssPresso-Android.apk](https://github.com/iakmds/rsspresso/releases) file from the GitHub [releases](https://github.com/iakmds/rsspresso/releases) page.

### Windows

Download and execute the [rssPresso-Windows.exe](https://github.com/iakmds/rsspresso/releases) file from the GitHub [releases](https://github.com/iakmds/rsspresso/releases) page.

### Linux

Supported | Planned
|-|-|
| AppImage | Flatpak (Flathub) |
| .deb | .rpm |
| | Snap |
| | AUR |

<br>

To install rssPresso as an **AppImage**, download the [rssPresso-Linux.AppImage](https://github.com/iakmds/rsspresso/releases) file from the GitHub [releases](https://github.com/iakmds/rsspresso/releases) page, make it executable and run it. For better desktop integration consider using [AppImageLauncher](https://github.com/TheAssassin/AppImageLauncher).

[<img src=".github/appimage-badge.svg"
    alt="Download as an AppImage"
    height="80">](https://github.com/iakmds/rsspresso/releases)

<br>

To install rssPresso as a **.deb** package, download the [rssPresso-Linux.deb](https://github.com/iakmds/rsspresso/releases) file from the GitHub [releases](https://github.com/iakmds/rsspresso/releases) page and install it.

# Features

* Import & export your feeds via OPML files
* Load the full content of an article
* Star articles & mark articles as read/unread
* Search for articles
* Filter feeds by unread or saved articles
* Material design with a light & dark theme
* Switch between different UI layouts
* Free and open source (GPLv3)
* *...and [many more features planned](#roadmap)*

# Contributing

These are the ways you can contribute to rssPresso:

### Bug reports, feature requests and improvements

Open an issue on GitHub: [Open issue](https://github.com/iakmds/rsspresso/issues). Remember to check for duplicates and try to give important information such as the app version, your operating system, etc.

### Code

Feel free to send in a [pull request](https://github.com/iakmds/rsspresso/pulls)! To get started with Flutter, follow this link: [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)

1. Clone this repository
2. Switch to the project's directory and run `flutter pub get` to get all necessary packages. To test the app, run the project in debug mode by selecting a device in your preferred Flutter IDE and running the app in debug mode
3. Build rssPresso (see steps for the different platforms below)

**Windows** executable: Run the following command in your terminal on a Windows machine: `flutter build windows` – the output file will be generated at `rsspresso\build\windows\runner\Release\rsspresso.exe`.

**Linux** executable: Run the following command in your terminal: `flutter build linux` – the output files, including the executable, will be generated at `rsspresso/build/linux/x64/release/bundle`.

# Roadmap
- [ ] Upload on F-Droid [Android]
- [ ] Upload on Flathub [Linux]
- [ ] Organize feeds into custom groups
- [ ] Sync with RSS services like the Fever API, Google Reader API, Nextcloud News, Feedbin, Inoreader, etc.
- [ ] Integrate YouTube subscriptions
- [ ] Background article fetching
- [ ] Desktop keyboard shortcuts
- [ ] Push notifications for desktop & mobile
- [ ] Multi-language support
- [ ] [Your features](https://github.com/iakmds/rsspresso/issues)

# Packages used

The packages used for this app, also listed in the pubspec.yaml file. See their respective licenses.

Package | Use case
-|-
[cached_network_image](https://pub.dev/packages/cached_network_image) | Cache images from the network
[content_parser](content_parser/) | Load full article content
[dart_rss](https://pub.dev/packages/dart_rss) | Parse RSS/Atom xml data
[file_picker](https://pub.dev/packages/file_picker) | Import/export OPML files
[flutter_file_dialog](https://pub.dev/packages/flutter_file_dialog) | Export OPML files on Android
[flutter_markdown](https://pub.dev/packages/flutter_markdown) | Display Markdown data
[flutter_riverpod](https://pub.dev/packages/flutter_riverpod) | State management
[html](https://pub.dev/packages/html) | Parse HTML data
[html2md](https://pub.dev/packages/html2md) | Convert HTML to Markdown
[http](https://pub.dev/packages/http) | Request website data
[intl](https://pub.dev/packages/intl) | Parse dates
[package_info_plus](https://pub.dev/packages/package_info_plus) | Display app version number
[path](https://pub.dev/packages/path) | Path transformations
[path_provider](https://pub.dev/packages/path_provider) | Load platform specific paths
[permission_handler](https://pub.dev/packages/permission_handler) | Show Android permission dialog
[shared_preferences](https://pub.dev/packages/shared_preferences) | Save/load app data
[url_launcher](https://pub.dev/packages/url_launcher) | Open URLs in Browser
[window_manager](https://pub.dev/packages/window_manager) | Desktop window operations
[xml](https://pub.dev/packages/xml) | Parse xml data

# Credits
This project was greatly inspired by other RSS readers. Without these projects, rssPresso wouldn't have looked the same as now.
- [Fluent Reader](https://github.com/yang991178/fluent-reader) (Desktop)
- [Fluent Reader Lite](https://github.com/yang991178/fluent-reader-lite) (Android)
- [Feeder](https://github.com/spacecowboy/Feeder) (Android)

### Extracting content: [content_parser](content_parser/)
To extract the full content of an article, [content_parser](content_parser/) is used. This is an incomplete port from the JavaScript library [Postlight Parser](https://github.com/postlight/parser) to Dart. Postlight Parser itself is licensed under the MIT License (see [here](https://github.com/postlight/parser/blob/main/LICENSE-MIT)).

# License

This project is licensed under the [GNU General Public License Version 3](https://www.gnu.org/licenses/gpl-3.0.html). For details, see [LICENSE](LICENSE).
