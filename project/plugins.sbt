// Comment to get more information during initialization
logLevel := Level.Warn

resolvers ++= Seq(
  DefaultMavenRepository,
  "Typesafe Repository" at "http://repo.typesafe.com/typesafe/releases/"
)

addSbtPlugin("com.typesafe.play" % "sbt-plugin" % "2.4.8")

addSbtPlugin("com.typesafe.sbt" % "sbt-coffeescript" % "1.0.0")

addSbtPlugin("com.typesafe.sbt" % "sbt-web" % "1.4.0")

addSbtPlugin("com.typesafe.sbt" % "sbt-less" % "1.1.0")