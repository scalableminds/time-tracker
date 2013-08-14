define ["moment"], ->

  class Report

    constructor : ->
  
      @currentDate = moment()


    setupUI : ->

      #timespan switching
        $(".month_picker .month_back").on "click", => 
          @currentDate.subtract("months", 1)
          @loadData()
        $(".month_picker .month_forward").on "click", =>
          @currentDate.add("months", 1)
          @loadData()


    #utilities
    padNumber : (number) ->

      String("0#{number}").slice(-2)
