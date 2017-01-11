import sbt._
import Keys._
import play.sbt.Play.autoImport._
import play.sbt.PlayImport
import play.sbt.routes.RoutesKeys._
import com.typesafe.sbt.web._
import play.twirl.sbt.SbtTwirl

trait Dependencies{
  val akkaVersion = "2.4.1"
  val reactiveVersion = "0.11.13"
  val reactivePlayVersion = "0.11.13-play24"
  val scmUtilVersion= "8.21.0"

  val commonsIo = "commons-io" % "commons-io" % "2.4"
  val commonsEmail = "org.apache.commons" % "commons-email" % "1.3.1"
  val reactivePlay = "org.reactivemongo" %% "play2-reactivemongo" % reactivePlayVersion
  val reactiveBson = "org.reactivemongo" %% "reactivemongo-bson-macros" % reactiveVersion
  val scmUtil = "com.scalableminds" %% "util" % scmUtilVersion
  val joda = "joda-time" % "joda-time" % "2.2"
  val akkaAgent = "com.typesafe.akka" %% "akka-agent" % akkaVersion
  val akkaLogging = "com.typesafe.akka" %% "akka-slf4j" % akkaVersion
}

trait Resolvers {
  val novusRel = "repo.novus rels" at "http://repo.novus.com/releases/"
  val novuesSnaps = "repo.novus snaps" at "http://repo.novus.com/snapshots/"
  val sonaRels = "sonatype rels" at "https://oss.sonatype.org/content/repositories/releases/"
  val sonaSnaps = "sonatype snaps" at "https://oss.sonatype.org/content/repositories/snapshots/"
  val sgSnaps = "sgodbillon" at "https://bitbucket.org/sgodbillon/repository/raw/master/snapshots/"
  val manSnaps = "mandubian" at "https://github.com/mandubian/mandubian-mvn/raw/master/snapshots/"
  val typesafeRel = "typesafe" at "http://repo.typesafe.com/typesafe/releases"
  val scmRel = "scm.io releases S3 bucket" at "https://s3-eu-central-1.amazonaws.com/maven.scm.io/releases/"
  val scmSnaps = "scm.io snapshots S3 bucket" at "https://s3-eu-central-1.amazonaws.com/maven.scm.io/snapshots/"
  val sbPlugins = Resolver.url("sbt-plugin-releases", new URL("http://repo.scala-sbt.org/scalasbt/sbt-plugin-releases/"))(Resolver.ivyStylePatterns)
}

object ApplicationBuild extends Build with Dependencies with Resolvers{

  val appName         = "time-tracker"
  val appVersion      = "1.0-SNAPSHOT"

  val appDependencies = Seq(
    cache,
    // Add your project dependencies here,
    reactivePlay,
    reactiveBson,
    commonsIo,
    commonsEmail,
    akkaAgent,
    joda,
    scmUtil,
    akkaLogging)

  val dependencyResolvers = Seq(
    novusRel,
    novuesSnaps,
    sonaRels,
    sonaSnaps,
    sgSnaps,
    manSnaps,
    typesafeRel,
    scmRel,
    scmSnaps,
    sbPlugins
  )

  lazy val appSettings = Seq(
    scalaVersion := "2.11.7",
    scalacOptions += "-target:jvm-1.8",
    version := appVersion,
    routesGenerator := InjectedRoutesGenerator,
    libraryDependencies ++= appDependencies,
    resolvers ++= dependencyResolvers
  )

  val main = Project(appName, file("."))
             .enablePlugins(play.sbt.PlayScala)
             .enablePlugins(SbtWeb)
             .settings(appSettings:_*)
}
