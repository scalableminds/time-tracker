import sbt._
import Keys._
import play.Project._

object ApplicationBuild extends Build {

  val appName         = "time-tracker"
  val appVersion      = "1.0-SNAPSHOT"

  val appDependencies = Seq(
    // Add your project dependencies here,
    "org.reactivemongo" %% "play2-reactivemongo" % "0.9",
    "org.reactivemongo" %% "reactivemongo-bson-macros" % "0.9",
    "commons-io" % "commons-io" % "1.3.2",
    //"com.typesafe.play" %% "play-json" % "2.2.0-M1",
    "org.apache.commons" % "commons-email" % "1.2",
    "com.typesafe.akka" %% "akka-agent" % "2.1.0",

    "com.scalableminds" %% "securesocial" % "master-SNAPSHOT",
    //"com.micronautics" %% "securesocial" % "2.1.1-SNAPSHOT",
    "com.scalableminds" %% "braingames-util" % "0.1-SNAPSHOT"
    )

  val dependencyResolvers = Seq(
    Resolver.url("Scala SBT PLUGIN REL Repo", url("http://repo.scala-sbt.org/scalasbt/sbt-plugin-releases"))(Resolver.ivyStylePatterns),
    Resolver.url("Scala SBT REL Repo", url("http://repo.scala-sbt.org/scalasbt/repo/"))(Resolver.ivyStylePatterns),
    Resolver.url("Scalableminds SNAPS Repo", url("http://scalableminds.github.com/snapshots/"))(Resolver.ivyStylePatterns),
    Resolver.url("Scalableminds REL Repo", url("http://scalableminds.github.com/releases/"))(Resolver.ivyStylePatterns))


  val main = play.Project(appName, appVersion, appDependencies).settings(
    // Add your own project settings here      
    resolvers ++= dependencyResolvers
  )

}
