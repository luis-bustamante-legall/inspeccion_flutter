# legall_rimac_virtual

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Setup Firebase

To assign the Firebase account that we want to use, we must first register the Android application.

## Register the Android application
1. Go to [Firebase console](https://console.firebase.google.com/) and select the project to connect
2. Open project settings

![](.README_images/4b3d69d.png)

3. Go to "Your apps" section and then click on Add app

![](.README_images/d0d8d15.png)

4. Now select Android as your platform

![](.README_images/75b92a4.png)

5. Fill the Android package name field this should be "com.giniem.rimac_virtual" for this project
6. Give the app a nickname (If you want)
7. Click on "Register app"

![](.README_images/570322a.png)

8. Download the `google-services.json` file

![](.README_images/0ad5ecc.png)

This file should be placed on `android/app/google-services.json`

## Create a database
If you not have a database you will need create one

1. In the sidebar click on `Cloud Firestore`
2. Click on `Create database`

![](.README_images/268d5f2.png)

3. Select the start mode that you want and click `Next`

![](.README_images/68764fe.png)

4. Select the desired location and click `Enable`

![](.README_images/4023314.png)


## Authentication
The application uses anonymous authentication so you need enable the sign-in method

1. Click `Authentication` on sidebar
2. Click `Sign-in method`
3. Switch on `Enable` on `Anonymous` sign-in method
4. Click `Save`

![](.README_images/09b0191.png)

## Indexes
Two indexes are required for the application, both with scope `Collection`

1. Collection `chats` for fields:
    - `inspection_id` order `Ascending`
    - `datetime` order `Ascending`
2. Collection `photos` for fields:
    - `inspection_id` order `Ascending`
    - `type` order `Ascending`
    - `group` order `Descending`

To add a new index:

1. Click `Cloud Firestore` on sidebar
2. Click `Indexes` tab
3. Click `Add index`

![](.README_images/e8d0dbc.png)


## Setup Google Maps

The project require a `API KEY` for `Maps SDK for Android` so if you not have one will need create.

## Enable the API
1. Go to [Console](https://console.cloud.google.com/)
2. Select the project
3. Click `APIs & Services` on sidebar
4. Click `Dashboard`

![](.README_images/b7ad0ba.png)

5. Click `ENABLE APIS AND SERVICES`

![](.README_images/a35a41e.png)

6. Click `Maps SDK for Android`

![](.README_images/f51dff4.png)

7. Click `Enable`

![](.README_images/6337e37.png)

## Create the API KEY

1. Click `APIs & Services` on sidebar
2. Click `Credentials`

![](.README_images/1aeebce.png)

3. Click `CREATE CREDENTIALS`
4. Click `API key`

![](.README_images/6a1d80b.png)

5. Copy the API key from the dialog

![](.README_images/4a7cdf4.png)

## Setup API KEY

The `API key` should be set on the file `android/app/src/main/AndroidManifest.xml` as in the image

![](.README_images/1aac873.png)

## Setup Azure Storage Account

The application use a Storage account and a `Shared access signature` (SAS) to access at the service.

If you not have a Storage account o need create one follow the next steps:

1. Go to `Panel` and click `Storage accounts`

![](.README_images/c5f272e.png)

2. Click `New` and fill the form, make sure that the account is StorageV2 on the `Account kind` field
3. Click Review + create button

![](.README_images/a2789d3.png)

4. Go to `Panel` and click on your new storage account
5. On sidebar click `Shared access signature`
6. Check `File` on `Allowed services` the other services are not needed but nothing happens if they are left checked
7. Check the permissions as on the next image

![](.README_images/22e321d.png)

8. Select the Start and expiry date/time, take into account that once the signature expires the app will not be able to connect with the service

![](.README_images/d9135b1.png)

9. Click `Generate SAS and connection string`
10. Copy the SAS token

![](.README_images/0deccb4.png)

11. On the project edit the file `lib/configuration.dart` change the `accountName` setting and paste the SAS token on the `SASToken` setting.
`Note: Please note that the SAS token obtained starts with the sign '?' skip it when pasting`

![](.README_images/908b3c6.png)



