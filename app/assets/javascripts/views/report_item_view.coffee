###  define
backbone.marionette : Marionette
underscore: _
utils: Utils
###

class ReportItemView extends Backbone.Marionette.ItemView

  tagName : "tr"

  template : _.template("""
    <td><%= name %></td>
    <td><%= Utils.minutesToHours(sum) %></td>
    <% _.each(dailyTimeEntries, function(day){ %>
      <td><%= Utils.minutesToHours(day) %></td>
    <% }) %>
  """)

  templateHelpers :
    Utils : Utils

  className : ->

    if @model.get("isHeader") then "project-row" else ""

#addIssueTooltips : (controller) ->

#     $("[rel=tooltip").each( (index, element) ->
#       $el = $(element)

#       [repo, issue] = [$el.data("repo"), $el.data("issue")]

#       controller.getIssueTitle(repo, issue).done( (issueTitle) ->


#         if issueTitle.length > 53
#           # display full name in tooltip

#           $el.tooltip(
#             "placement" : "right"
#             "title" : issueTitle
#           )

#           issueTitle = issueTitle.slice(0, 50) + "..."

#         $el.parent().append("  " + issueTitle)

#       )
#     )