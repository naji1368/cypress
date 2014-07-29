@App.module "TestSpecsApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Test extends App.Views.ItemView
    template: "test_specs/list/_test"
    className: "test"

    ui:
      pre: "pre"
      label: "label"

    events:
      "click @ui.pre" : "preClicked"
      "mouseover"     : "mouseover"
      "mouseout"      : "mouseout"

    modelEvents:
      "change:state"  : "stateChanged"
      "change:error"  : "errorChanged"
      "change:chosen" : "chosenChanged"

    triggers:
      "click" : "test:clicked"

    mouseover: (e) ->
      e.stopPropagation()
      @$el.addClass("hover")

    mouseout: (e) ->
      e.stopPropagation()
      @$el.removeClass("hover")

    chosenChanged: (model, value, options) ->
      @$el.toggleClass "active", value

    onBeforeRender: ->
      @$el.addClass @model.get("state")

    stateChanged: (model, value, options) ->
      @$el.removeClass("processing failed passed").addClass(value)

      ## if the test passed check on the duration
      @checkDuration() if value is "passed"
      @checkTimeout() if value is "failed"

    checkDuration: ->
      return if not @model.isSlow()

      ## need to add a tooltip here
      @ui.label.addClass("label-primary").text(@model.get("duration") + "ms")

    checkTimeout: ->
      return if not @model.timedOut()

      @ui.label.addClass("label-danger").text("Timed Out")

    errorChanged: (model, value, options) ->
      value or= ""
      @ui.pre.text(value)

    preClicked: (e) ->
      return if not error = @model.originalError

      ## log out to the console the original error
      ## this nukes the original stack trace though...
      console.error(error)

  class List.Suite extends App.Views.CompositeView
    template: "test_specs/list/_suite"
    className: "suite"
    childViewContainer: "ul"

    events:
      "mouseover"   : "mouseover"
      "mouseout"    : "mouseout"

    triggers:
      "click" : "suite:clicked"

    modelEvents:
      "change:state"  : "stateChanged"
      "change:chosen" : "chosenChanged"

    getChildView: (model) ->
      switch model.get("type")
        when "suite" then List.Suite
        when "test" then List.Test

    mouseover: (e) ->
      @$el.addClass("hover")

    mouseout: (e) ->
      @$el.removeClass("hover")

    initialize: ->
      @collection = @model.get("children")

    chosenChanged: (model, value, options) ->
      @$el.toggleClass "active", value

    onBeforeRender: ->
      @$el.addClass @model.get("state")

    stateChanged: (model, value, options) ->
      @$el.removeClass("processing failed passed").addClass(value)

  class List.Suites extends App.Views.CollectionView
    className: "suite"

    childView: List.Suite

  class List.Runnable extends App.Views.CollectionView
    tagName: "ul"
    id: "specs-container"

    getChildView: (model) ->
      switch model.get("type")
        when "suite" then List.Suite
        when "test" then List.Test

    initialize: ->
      @collection = @model.get("children")
