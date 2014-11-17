## NotificationHub

### Overview
Strictly typed ```NSNotificationCenter``` in Swift suitable for games that has large scale pub/sub
* Same behaviour and similar API as ```NSNotificationCenter```
* Using default arguments for syntatic sugar, e.g. omit ```sender``` and ```userInfo```
* Adds acknowledgment for publish and removing subscribers/observers.
* Adds generics for strict typing on ```userInfo``` e.g. ```NotificationHub<[String : [UIView]]>```
* Comes with singleton ```NotificationHubDefault``` which is ```NotificationHub<[String : Any]>```
* Faster performance with larger scale for both publish/posting and subscribing/observing.


