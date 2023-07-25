# Parker Smart Parking Assistant

Parker is an automatic Smart Parking Assistant (SPA) that will completely handle the working of a parking lot.

![CSE564-Parker-Presentation](https://github.com/patelb268/Parker-Smart-Parking-Assistant/assets/109325051/13879798-6d41-42c8-a64d-e048e21cc565)


https://github.com/patelb268/Parker-Smart-Parking-Assistant/assets/109325051/7829d24f-1e89-45d2-b8b7-8b1a298b7254

## Features

It has the following features:
* Customized user login
* Handle a parking lot of 404 spots with sensors
* Obtain nearest available parking
* Guide the user to the assigned parking
* Add payment cards and ease payments without any human intervention

Sensors: For the 404 parkings, Parker will be using an array of 404 proximity sensors and those sensors will detect if there is any car parked in the parking or not. Using this information, the server fetch the nearest available parking using BFS in the grid.

## installation instructions

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


![CSE564-Parker-Presentation](https://github.com/patelb268/Parker-Smart-Parking-Assistant/assets/109325051/11d26bb3-d663-4f26-8625-f283213a821f)
![CSE564-Parker-Presentation (1)](https://github.com/patelb268/Parker-Smart-Parking-Assistant/assets/109325051/54a216b0-e3f7-4442-8a0c-d62cdc1f3f48)
![CSE564-Parker-Presentation (2)](https://github.com/patelb268/Parker-Smart-Parking-Assistant/assets/109325051/248c782d-1527-4be1-906b-aa7a558ea2aa)
![CSE564-Parker-Presentation (3)](https://github.com/patelb268/Parker-Smart-Parking-Assistant/assets/109325051/e32963a8-30d2-4661-adea-f60499e877bf)

