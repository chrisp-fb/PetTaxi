## Demonstration app for AngelHack Seattle Nov 2 2013
This is an app inspired by Uber for kittens. It's a contrived two
view app that lets the user choose some pets from a map view
and "order" them for delivery. It does not communicate to any
back end and all its data are either hard coded or randomly generated.

## Facebook Integration
After the initial implementation, we add Facebook integration:

1. To allow a share after the "order" via the Native Share Dialog.
2. To login via the FBLoginView control on the map view view controller.
3. To fetch the user's friends (that also have the app installed)
 after login.
 
To run the app with Facebook integration, you need to configure
an appropriate app on http://developers.facebook.com/apps,
specifically

1. name as "PetTaxi"
2. an iOS app with a bundle id of "PetTaxi"
3. set a namespace
4. add an open graph story of "hire pet".
5. link the Facebook SDK framework in the app correctly.

For more details about Facebook integration or learn more, check
out http://developers.facebook.com/ios
