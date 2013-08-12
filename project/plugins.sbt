// Comment to get more information during initialization
logLevel := Level.Warn

// The Typesafe repository 
resolvers ++= Seq(
    "Typesafe repository REL" at "http://repo.typesafe.com/typesafe/releases/",
    Resolver.url("Scalableminds REL Repo", url("http://scalableminds.github.com/releases/"))(Resolver.ivyStylePatterns))

// Use the Play sbt plugin for Play projects
addSbtPlugin("play" % "sbt-plugin" % "2.1.2-SCM")

addSbtPlugin("com.github.mpeltonen" % "sbt-idea" % "1.5.1")
