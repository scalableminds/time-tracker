### define
backbone : backbone
moment : moment
Utils : Utils
models/user_time_collection : UserTimeCollection
models/team/team_viewmodel : TeamViewModel
###

# #############
# User ViewModel
#
# Handles the transformation of the general UserTimeModel data for the
# 'me' view and serves common view models attributes for this view.
# #############

class UserViewModel extends TeamViewModel

  defaults :
    date : moment()
    rows : new Backbone.Collection()
    monthlyTotalHours : 0
    dailyTotalHours : 0
    urlRoot : "home"
    viewTitle : "User Report"

  dataSource : UserTimeCollection

