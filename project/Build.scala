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
    "org.apache.commons" % "commons-email" % "1.2",
    "com.typesafe.akka" %% "akka-agent" % "2.1.0",
    "com.scalableminds" %% "braingames-util" % "0.1-SNAPSHOT"
    )

  val dependencyResolvers = Seq(
    Resolver.url("Scalableminds SNAPS Repo", url("http://scalableminds.github.com/snapshots/"))(Resolver.ivyStylePatterns),
    Resolver.url("Scalableminds REL Repo", url("http://scalableminds.github.com/releases/"))(Resolver.ivyStylePatterns))


  val main = play.Project(appName, appVersion, appDependencies).settings(
    // Add your own project settings here      
    resolvers ++= dependencyResolvers
  )

}
