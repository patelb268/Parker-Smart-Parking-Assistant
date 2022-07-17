Parker is an automatic Smart Parking Assistant (SPA) that will completely handle the working of a parking lot.

It has the following features:
* Customized user login
* Handle a parking lot of 404 spots with sensors
* Obtain nearest available parking
* Guide the user to the assigned parking
* Add payment cards and ease payments without any human intervention

Sensors: For the 404 parkings, Parker will be using an array of 404 proximity sensors and those sensors will detect if there is any car parked in the parking or not. Using this information, the server fetch the nearest available parking using BFS in the grid.

<----------------------------------installation instructions--------------------------------->

#### Required tools

* [Flutter](https://docs.flutter.dev/get-started/install)
* [Android Studio](https://developer.android.com/studio)
* [java jdk 8](https://www.oracle.com/java/technologies/downloads/)

#### HOW TO USE :

* Clone the repository locally.
* Open Android Studio(version 2.3 and above) with Flutter and Dart plug-ins installed.
* Open the cloned project.
* Browse to **pubspec.yaml** file and use the `pub get` command on the dependencies to download and install them.
> You may use pub get directly too. This is to look at the plug-ins which need to be installed for this app.
* Sync the gradles.
> To sync the gradles in Android Studio, right click on the Android folder in your Flutter project. Navigate to the "Flutter" option and select "Open for editing in Android Studio". Once it opens, sync will start automatically. You may also click on the gradle-build icon present on the top panel.
* Do configurations if necessary(Use `main.dart` as the Dart EntryPoint).
* Connet peripherial device(android) with USB debugging.
* Run the app.
* The app will be built and get installed automatically if everything is correct.
> While running for the first time, `Gradle task 'assembleDebug'...` might take a little time. 
> After that, the app will be ready to use.