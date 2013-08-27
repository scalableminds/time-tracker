import sbt._
import Keys._
import play.Project._

object ApplicationBuild extends Build {

  val appName         = "time-tracker"
  val appVersion      = "1.0-SNAPSHOT"

  val coffeeCmd =
    if(System.getProperty("os.name").startsWith("Windows"))
      "cmd /C coffee -p"
    else
      "coffee -p"

  val appDependencies = Seq(
    // Add your project dependencies here,
    "org.reactivemongo" %% "play2-reactivemongo" % "0.9",
    "org.reactivemongo" %% "reactivemongo-bson-macros" % "0.9",
    "commons-io" % "commons-io" % "1.3.2",
    //"com.typesafe.play" %% "play-json" % "2.2.0-M1",
    "org.apache.commons" % "commons-email" % "1.2",
    "com.typesafe.akka" %% "akka-agent" % "2.1.0",
    "joda-time" % "joda-time" % "2.2",
    "com.scalableminds" %% "braingames-util" % "0.3",
    "com.scalableminds" %% "securesocial" % "2.1.0-SCM"
    //"com.micronautics" %% "securesocial" % "2.1.1-SNAPSHOT",
    )

  val dependencyResolvers = Seq(
    Resolver.url("Scala SBT PLUGIN REL Repo", url("http://repo.scala-sbt.org/scalasbt/sbt-plugin-releases"))(Resolver.ivyStylePatterns),
    Resolver.url("Scala SBT REL Repo", url("http://repo.scala-sbt.org/scalasbt/repo/"))(Resolver.ivyStylePatterns),
    Resolver.url("Scalableminds SNAPS Repo", url("http://scalableminds.github.com/snapshots/"))(Resolver.ivyStylePatterns),
    Resolver.url("Scalableminds REL Repo", url("http://scalableminds.github.com/releases/"))(Resolver.ivyStylePatterns))


  val main = play.Project(appName, appVersion, appDependencies).settings(
    // Add your own project settings here      
    resolvers ++= dependencyResolvers,
    coffeescriptOptions := Seq(/*"minify",*/ "native", coffeeCmd)
  )

}
