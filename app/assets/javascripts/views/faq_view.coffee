### define
underscore : _
backbone.marionette : Marionette
###

class FAQView extends Backbone.Marionette.ItemView

  template : """"
    <h2>Frequently Asked Questions</h2>
    <h3>What is an 'automatic time tracking link' for Github Issues?</h3>
    <p>The TimeTracker can be configured to automatically add a weblink pointing to your time tracker profile on every Github Issue in your repositories. Both existing issues and newly created issues will be affected. This feature is meant to provide you with an easy and convient way of tracking time within Github issue tracking.</p>

    <h3>At what interval are the links added to issues?</h3>
    <p>Existing issues will benefit from this feature once you active a repository in TimeTrack and enable the 'automatic time-tracking link' option. Newly created issues will also be assigned a link instantly on creation, by means of the Github hooks API.</p>

    <h3>What is an 'access token' and where can I get mine?</h3>

    <h3>How can I change the TimeTracker's access permission to my Github account after signing up?</h3>
  """
