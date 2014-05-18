# [![Time-Tracker logo](https://timer.scm.io/assets/images/stopwatch.png) Time-Tracker](https://timer.scm.io)
Time tracking for Github issues.

## Features
* Log your time for each issue you work on
* Get an overview of your and your team's work
* Injects links into Github issues for easy tracking
* Uses Github user accounts and repository settings


## Dependencies

* [Java JDK 1.7 (Oracle version)](http://www.oracle.com/technetwork/java/javase/downloads/index.html)
* [sbt](http://www.scala-sbt.org/)
* [mongoDB 2.4.3+](http://www.mongodb.org/downloads)
* [node.js 0.10.0+](http://nodejs.org/download/)
* [git](http://git-scm.com/downloads)
* [bower](http://bower.io/)

## Installation
```bash
git clone git@github.com:scalableminds/time-tracker.git
cd time-tracker
bower install
sbt run
```

Scala and Java dependencies will automatically be downloaded. The application will be running on [Port 9000](http://localhost:9000/).

## Credits
[scalable minds](http://scm.io/)

## License
[MIT 2014 scalable minds](https://github.com/scalableminds/time-tracker/blob/master/LICENSE)