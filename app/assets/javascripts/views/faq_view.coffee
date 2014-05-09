### define
underscore : _
backbone.marionette : Marionette
###

class FAQView extends Backbone.Marionette.ItemView

  className : "faq"
  template : _.template("""
    <h2>Frequently Asked Questions</h2>

    <a></a>
    <h4>What is an 'automatic time tracking link' for Github Issues?</h4>
    <p>The TimeTracker can be configured to automatically add a weblink pointing to your time tracker profile on every Github Issue in your repositories. Both existing issues and newly created issues will be affected. This feature is meant to provide you with an easy and convient way of tracking time within Github issue tracking.</p>

    <a></a>
    <h4>At what interval are the links added to issues?</h4>
    <p>Existing issues will benefit from this feature once you active a repository in TimeTrack and enable the 'automatic time-tracking link' option. Newly created issues will also be assigned a link instantly on creation, by means of the Github hooks API.</p>

    <a></a>
    <h4>What is an 'access token' and where can I get mine?</h4>
    <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Possimus, accusamus, asperiores aliquam dignissimos quibusdam illo fuga veniam ipsa optio quia delectus tenetur rerum nisi ea labore. Esse, deleniti neque alias!</p>

    <a></a>
    <h4>How can I change the TimeTracker's access permission to my Github account after signing up?</h4>
    <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Possimus, accusamus, asperiores aliquam dignissimos quibusdam illo fuga veniam ipsa optio quia delectus tenetur rerum nisi ea labore. Esse, deleniti neque alias!</p>

    <a></a>
    <h4>How can I change the TimeTracker's access permission to my Github account after signing up?</h4>
    <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Possimus, accusamus, asperiores aliquam dignissimos quibusdam illo fuga veniam ipsa optio quia</p>

    <a></a>
    <h4>How can I change the TimeTracker's access permission to my Github account after signing up?</h4>
    <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Possimus, accusamus, asperiores aliquam dignissimos quibusdam illo fuga veniam ipsa optio quia</p>

    <a></a>
    <h4>How can I change the TimeTracker's access permission to my Github account after signing up?</h4>
    <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Possimus, accusamus, asperiores aliquam dignissimos quibusdam illo fuga veniam ipsa optio quia</p>
  """)

  initialize : ->

    @listenTo(@, "render", @afterRender)


  afterRender : ->

    # add unique question identifier
    @$("a").each((i, element) ->
      $(element).prop("id", "q#{i + 1}")
    )

    # jump to the right question
    if hashTag = window.location.hash
      _.defer( ->
        el = $("#{hashTag}")[0]
        el.scrollIntoView()
      )

    # highlight question
    @$("#{hashTag}").next().addClass("highlight")

