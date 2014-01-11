import sbt._
import Keys._
import play.Project._

trait Dependencies{
  val akkaVersion = "2.2.0"
  val reactiveVersion = "0.10.0"
  val reactivePlayVersion = "0.10.2"
  val braingamesVersion = "1.3.0"

  val commonsIo = "commons-io" % "commons-io" % "2.4"
  val commonsEmail = "org.apache.commons" % "commons-email" % "1.3.1"
  val reactivePlay = "org.reactivemongo" %% "play2-reactivemongo" % reactivePlayVersion
  val reactiveBson = "org.reactivemongo" %% "reactivemongo-bson-macros" % reactiveVersion
  val braingamesUtil = "com.scalableminds" %% "braingames-util" % braingamesVersion
  val securesocial = "securesocial" %%  "securesocial" % "2.1.2" withSources()
  val joda = "joda-time" % "joda-time" % "2.2"
  val akkaAgent = "com.typesafe.akka" %% "akka-agent" % akkaVersion
  val typesafeMailer = "com.typesafe" %% "play-plugins-mailer" % "2.2.0"
}

trait Resolvers {
  val novusRel = "repo.novus rels" at "http://repo.novus.com/releases/"
  val novuesSnaps = "repo.novus snaps" at "http://repo.novus.com/snapshots/"
  val sonaRels = "sonatype rels" at "https://oss.sonatype.org/content/repositories/releases/"
  val sonaSnaps = "sonatype snaps" at "https://oss.sonatype.org/content/repositories/snapshots/"
  val sgSnaps = "sgodbillon" at "https://bitbucket.org/sgodbillon/repository/raw/master/snapshots/"
  val manSnaps = "mandubian" at "https://github.com/mandubian/mandubian-mvn/raw/master/snapshots/"
  val typesafeRel = "typesafe" at "http://repo.typesafe.com/typesafe/releases"
  val scmRel = Resolver.url("Scalableminds REL Repo", url("http://scalableminds.github.com/releases/"))(Resolver.ivyStylePatterns)
  val scmIntRel = Resolver.sftp("scm.io intern releases repo", "scm.io", 44144, "/srv/maven/releases/") as("maven", "5MwEuHWH6tRPL6yfNadQ")
  val scmIntSnaps = Resolver.sftp("scm.io intern snapshots repo", "scm.io", 44144, "/srv/maven/snapshots/") as("maven", "5MwEuHWH6tRPL6yfNadQ")
  val sbPlugins = Resolver.url("sbt-plugin-releases", new URL("http://repo.scala-sbt.org/scalasbt/sbt-plugin-releases/"))(Resolver.ivyStylePatterns)
}

object ApplicationBuild extends Build with Dependencies with Resolvers{

  val appName         = "time-tracker"
  val appVersion      = "1.0-SNAPSHOT"

  val coffeeCmd =
    if(System.getProperty("os.name").startsWith("Windows"))
      "cmd /C coffee -p"
    else
      "coffee -p"

  val appDependencies = Seq(
    cache,
    // Add your project dependencies here,
    reactivePlay,
    reactiveBson,
    commonsIo,
    commonsEmail,
    akkaAgent,
    joda,
    braingamesUtil,
    typesafeMailer,
    securesocial)

  val dependencyResolvers = Seq(
    novusRel,
    novuesSnaps,
    sonaRels,
    sonaSnaps,
    sgSnaps,
    manSnaps,
    typesafeRel,
    scmRel,
    scmIntRel,
    scmIntSnaps,
    sbPlugins
  )

  val main = play.Project(appName, appVersion, appDependencies).settings(
    // Add your own project settings here      
    resolvers ++= dependencyResolvers,
    coffeescriptOptions := Seq("native", coffeeCmd)
  )
}
