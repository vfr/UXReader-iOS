### Using the UXReader PDF Framework for iOS

#### Getting Started

Since the framework depends on a single large binary library file (libpdfium.a), you should download
the latest [UXReader-iOS](https://github.com/vfr/UXReader-iOS/releases/download/0.1.0/UXReader-iOS.zip)
release ZIP. Once extracted, open Reader.xcworkspace in Xcode and then build and run to a device
(as the PDFium library does not support building for x86_64 simulator at this time).
Then use iTunes to sync PDF files to the sample Reader app.

Alternatively, you can clone the project from GitHub and copy libpdfium.a from the above ZIP into
the PDFium folder inside of the UXReader project folder.

To use the UXReader framework in your own apps, simply drag the UXReader project folder to your
Xcode workspace or project and set the dependencies to this iOS Framework to build and include
it in your app bundle.

#### Showing a Document

There are two classes that are required to show a document: `UXReaderDocument` and `UXReaderViewController`.
Use `#import <UXReader/UXReader.h>` to import their definitions.

First create a UXReaderDocument object:

`NSURL *URL = [NSURL fileURLWithPath:@"file:///path/to/user/file.pdf"];`
`UXReaderDocument *document = [[UXReaderDocument alloc] initWithURL:URL];`

then

`UXReaderViewController *readerViewController = [[UXReaderViewController alloc] init];`
`[readerViewController setDelegate:self]; [readerViewController setDocument:document];`
`[readerViewController setDisplayMode:UXReaderDisplayModeSinglePageScrollH];`

now present the view controller. Please see the `-openDocumentURL:` method in
[`ReaderViewController.mm`](https://github.com/vfr/UXReader-iOS/blob/master/Reader/Reader/ReaderViewController.mm)
in the Reader sample app for details on presenting as a modal or child view controller.
