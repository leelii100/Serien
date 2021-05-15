[![build and release](https://github.com/leelii100/serien/actions/workflows/release.yml/badge.svg?branch=master)](https://github.com/leelii100/serien/actions/workflows/release.yml)

<!-- PROJECT LOGO -->
<br/>
<p align="center">
  <a href="https://github.com/leelii100/Serien">
    <img src="lib/img/logo.svg" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">Serien</h3>

  <p align="center">
    Save your watched series and TV-shows and its current progress of watching in this app. Your data will be syncronized with your other devices. 
    <br/>
    <br/>
</p>



<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary><h2 style="display: inline-block">Table of Contents</h2></summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#server">Server</a></li>
        <li><a href="#application">Application</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
      <ul>
        <li><a href='#server'>Development server</a></li>
        <li><a href='#testing'>Testing</a></li>
        <li><a href='#build-android'>Build Android</a></li>
        <li><a href='#build-web'>Build Web</a></li>
      </ul>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

With Serien, you can save your watched series and TV-shows and its current progress of watching. You can confige informatin like the name, a link, a desciption, your position (season, episode) or wether you would like to use the TOR browser. Your data will be syncronized with your other devices using a local API Server. 


### Built With

* []() Flutter/Dart
* []() Python Flask for the REST API


<!-- GETTING STARTED -->
## Getting Started

To get a local copy up and running follow these simple steps.

### Prerequisites

This is a list of things you need to use the software and how to install them.
* [Flutter](https://flutter.dev/docs/get-started/install)
* [Python](https://www.python.org/downloads/)

### Server

* Clone the repo
   ```sh
   git clone https://github.com/leelii100/Serien -b server
   ```
* Install python modules
   ```Batchfile
   python3 -m pip install Flask flask-cors
   ```
### Application

* Clone the repo
   ```sh
   git clone https://github.com/leelii100/Serien
   ```


<!-- USAGE EXAMPLES -->
## Usage

### Server
In the server folder run
``` sh
python3 server.py
```
The REST API will be aviable on http://0.0.0.0:5000/.

### Testing
```sh
flutter run
```

### Build Android
``` sh
flutter build apk
```
The apk-file can be found in the `build/app/outputs/flutter-apk/` directory.

### Build Web
``` sh
flutter build web
```
The directory with the web-files can be found in `build/web/`. You can setup a local webserver for example with the npm plugin [lws](https://github.com/lwsjs/local-web-server/wiki). 
