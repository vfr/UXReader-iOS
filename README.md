
## UXReader PDF Framework for iOS

### Introduction

The UXReader PDF Framework for iOS is a fully open-source iOS PDF Framework based
on the open-source [PDFium](https://pdfium.googlesource.com/pdfium/) library.

### Features

* Document searching (with options).
* Single page horizontal and vertical scrolling.
* Double page horizontal and vertical scrolling.
* Right to Left and Left to Right UI and document presentation.
* Table of Contents (aka PDF outline or bookmark) extraction.
* Page text extraction (by co-ordinates or character index).
* Page links (goto page and URL).
* Page labels ("Cover", "i", "ii", etc).
* Document metadata extraction (Creator, etc).
* Local NSURL, NSData and custom document data sources.
* Experimental remote NSURL document data source.
* Custom overlay rendering object support (watermarking).
* Opening password protected documents.
* Device rotation and all orientations.

### Notes

The code is universal, written in Objective-C++ (works with Swift or plain
Objective-C) and does not require storyboards or NIBs (all UI elements are
generated in code with graphics resources bundled in the framework). It runs
on iPad, iPhone and iPod touch with iOS 9.0 and up and is ready to be fully
internationalized.

Please see the [HOWTO](https://github.com/vfr/UXReader-iOS/blob/master/HOWTO.md) for
getting started and the sample Reader project on how to use the UXReader framework
(class and method documentation is still on the todo list).

### Contact Info

Website: [http://www.vfr.org/](http://www.vfr.org/)

Email: joklamcak(at)gmail(dot)com

Twitter: [@joklamcak](https://twitter.com/joklamcak)

### License

This code has been made available under the MIT License.

### Screens

![iPad1](http://i.imgur.com/ucaBYZg.png)
![iPad2](http://i.imgur.com/xCdcvLR.png)
![iPad3](http://i.imgur.com/8FGW03U.png)
![iPad4](http://i.imgur.com/T2D3TlT.png)
![iPad5](http://i.imgur.com/yr6IJM0.png)
