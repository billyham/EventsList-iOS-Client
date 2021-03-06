## EventsList
__EventsList is an iOS app. It provides a listing of events for an independent theater.__

The project was started as a way to learn and put into practice Apple's recommended techniques for implementing CloudKit as a data transport mechanism. 

The intention is for the app to published and deployed by any theater organization, which posts information and images for upcoming dates for shows. Users of the app have this information available to them as a convenient source of upcoming events for the theater. 

EventsList uses Core Data as its local store, and it uses CloudKit to keep the Core Data cache up to date. Remote Notifications push new listings and changes from the CloudKit source to instances of the app. The code was written to follow the best practices set out in WWDC CloudKit talks from 2014, 2015 and 2016 as well as advice given by Marcus Zarra from a tech talk about [isolating network calls from View Controllers](https://realm.io/news/slug-marcus-zarra-exploring-mvcn-swift/)

_Copyright © 2016 Hamagain LLC. All rights reserved._
