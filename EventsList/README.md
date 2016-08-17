## EventsList
EventsList is an iOS app.  
It provides a listing of events for an independent movie theater.

The project was started as a way to learn and put into practice Apple's recommended techniques for implementing CloudKit as the data transport mechanism. 

The app is deployed by a movie theater, which posts information and images for upcoming show dates for movies. Users of the app have this information available to them as a convenient source of upcoming events for the theater. 

EventsList uses Core Data as its local store, and it uses CloudKit to keep the Core Data cache up to date. Remote Notifications push new listings and changes from the CloudKit source to instances of the app. The code was written to follow the best practices set out in WWDC CloudKit talks from 2014, 2015 and 2016 as well as advice given by Marcus Zarra from a tech talk about [isolating network calls from View Controllers](https://realm.io/news/slug-marcus-zarra-exploring-mvcn-swift/)