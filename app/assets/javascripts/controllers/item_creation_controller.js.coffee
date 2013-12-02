xplanItemCreationController = angular.module "xplanItemCreationController", [ ]

xplanItemCreationController.controller "itemCreationController", [ '$scope', '$rootScope', '$timeout', 'XplanItem',  ($scope, $rootScope, $timeout, XplanItem) ->
    initModal = () ->
        $scope.dirty = false
        $scope.alerts = [ ]
        $scope.suggestions = [ ]
        $scope.suggestionCount = 0
        if $scope.item != null
            $scope.item_title = angular.copy $scope.item.title
            $scope.item_details = angular.copy $scope.item.details
            $scope.tags = angular.copy $scope.item.tags
            # Some magic here because we have marker and infowindow saved on the location
            $scope.locations = [ ]
            angular.forEach $scope.item.locations, (location) ->
                location_copy = { }
                angular.forEach location, (value, key) ->
                    if key.substring(0,1) != "$"
                        location_copy[key] = value
                $scope.locations.push location_copy
            $scope.bookmarks = angular.copy $scope.item.bookmarks
            $scope.yelpInfos = angular.copy $scope.item.yelpInfos
        else
            $scope.item_title = ""
            $scope.item_details = ""
            $scope.tags = [ ]
            $scope.locations = [ ]
            $scope.bookmarks = [ ]
            $scope.yelpInfos = [ ]

    $('#addItemModal').modal
        show: false
    $('#addItemModal').on "hidden.bs.modal", () ->
        initModal()
    $("#addItemModal").on "hide.bs.modal", (event) ->
        if $scope.dirty
            confirm "Looks like you have some changes, are you sure you want to cancel your changes?"

    $rootScope.$on "item.create", (event, plan) ->
        $scope.item = null
        $scope.plan = plan
        initModal()
        $('#addItemModal').modal "show"

    $rootScope.$on "item.edit", (event, item, plan) ->
        $scope.item = item
        $scope.plan = plan
        initModal()
        $('#addItemModal').modal "show"

    timer = null
    debounce = (fn, delay) ->
        if timer != null
            $timeout.cancel timer
        timer = $timeout fn, delay

    isUrl = (value) ->
        pattern = /(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/
        pattern.test value

    deleteElement = (array, element) ->
        index = array.indexOf element
        array.splice index, 1

    addAlert = (alertMessage) ->
        $scope.alerts.push alertMessage
        $timeout () ->
            deleteElement $scope.alerts, alertMessage
        , 5000

    updateTitle = (title) ->
        if $scope.item_title == ""
            $scope.item_title = title
            addAlert "Added '" + title + "' as the title..."

    addBookmark = (value) ->
        $scope.dirty = true
        $scope.bookmarks.push
            element_type: "bookmark"
            name: value
        addAlert "Added '" + value + "' as a bookmark..."
        $scope.processing_message = "Looking up " + value + " ..."
        $scope.suggestionCount += 1
        XplanItem.info
            type: "bookmark"
            key: value
        .then (response) ->
            $scope.suggestionCount -= 1
            angular.forEach response.data.info, (info) ->
                if info.element_type == "title"
                    updateTitle info.name
                if info.element_type == "yelp"
                    $scope.yelpInfos.push info
                    addAlert "Added Yelp info for '" + info.name + "'"
                    updateTitle info.name

    $scope.removeBookmark = (value) ->
        $scope.dirty = true
        deleteElement $scope.bookmarks, value

    addTag = (tag) ->
        $scope.dirty = true
        addAlert "Added '" + tag.name + "' as a tag..."
        $scope.tags.push tag

    $scope.removeTag = (tag) ->
        $scope.dirty = true
        deleteElement $scope.tags, tag

    addLocation = (location) ->
        $scope.dirty = true
        $scope.processing_message = "Looking up info for " + location.value + " ..."
        $scope.suggestionCount += 1
        XplanItem.info
            type: "google_place"
            key: location.reference
        .then (response) ->
            $scope.suggestionCount -= 1
            angular.forEach response.data.info, (info) ->
                $scope.locations.push info
                addAlert "Added '" + info.name + "' as a location..."

    $scope.removeLocation = (value) ->
        $scope.dirty = true
        deleteElement $scope.locations, value

    $scope.removeYelpInfo = (value) ->
        $scope.dirty = true
        deleteElement $scope.yelpInfos, value

    resetSuggestions = () ->
        $scope.suggestions = [ ]
        $scope.magicValue = ""

    suggestionQueryCount = 0
    getSuggestions = (type, term) ->
        $scope.processing_message = "Searching for suggestions"
        $scope.suggestionCount += 1
        # Get tag suggestions
        suggestionQueryCount += 1
        queryNumber = suggestionQueryCount
        suggestionParams = 
            term: term
            type: type
        if type == "google_place"
            suggestionParams.location_bias = $scope.plan.destination.geometry.lat + "," + $scope.plan.destination.geometry.lng
        XplanItem.suggest(suggestionParams)
        .then (response) ->
            $scope.suggestionCount -= 1
            # Since we are executing two queries we are
            # letting the the query number to be  1 higher
            # than overall query count
            if queryNumber >= suggestionQueryCount - 1
                angular.forEach response.data.suggestions, (suggestion_data) ->
                    suggestion = { }
                    suggestion.type = response.data.suggestion_type
                    suggestion.data = suggestion_data
                    if response.data.suggestion_type == "tag"
                        suggestion.icon = "fa-tag"
                        suggestion.message = suggestion_data.name
                    else if response.data.suggestion_type == "google_place"
                        suggestion.icon = "fa-location-arrow"
                        suggestion.message = suggestion_data.value
                    else
                        console.log "Unknown type for suggestion: " + response.data.suggestion_type
                    $scope.suggestions.push suggestion

    $scope.magicInput = () ->
        debounce () ->
            if $scope.magicValue == ""
                # If the input is empty, reset the suggestions.
                resetSuggestions()
            else if isUrl $scope.magicValue
                # If we have a URL add it as a bookmark
                addBookmark $scope.magicValue
                resetSuggestions()
            else if $scope.magicValue.substring(0,1) == "#"
                # Get suggestions for tags only
                $scope.suggestions = [ ]
                getSuggestions "tag", $scope.magicValue.substring(1, $scope.magicValue.length)
            else if $scope.magicValue.substring(0,1) == "@"
                # Get suggestions for locations only
                $scope.suggestions = [ ]
                getSuggestions "google_place", $scope.magicValue.substring(1, $scope.magicValue.length)
            else
                # Otherwise get suggestions from the server
                $scope.suggestions = [ ]
                getSuggestions "tag", $scope.magicValue
                getSuggestions "google_place", $scope.magicValue
        , 500

    $scope.suggested = (suggestion) ->
        resetSuggestions()
        if suggestion.type == "tag"
            addTag suggestion.data
        else if suggestion.type == "google_place"
            addLocation suggestion.data

    $scope.submitItem = () ->
        $scope.dirty = false
        # TODO: Need to do some validation here...
        item_elements = [ ]
        angular.forEach $scope.locations, (location) ->
            item_elements.push location
        angular.forEach $scope.bookmarks, (bm) ->
            item_elements.push bm
        angular.forEach $scope.yelpInfos, (y) ->
            item_elements.push y
        if $scope.item == null
            item = XplanItem.createItem
                plan_id: $scope.plan.id
                title: $scope.item_title
                details: $scope.item_details
                tags: $scope.tags
                item_elements: item_elements
            item.$promise.then () ->
                $('#addItemModal').modal "hide"
        else
            item = XplanItem.editItem $scope.item,
                plan_id: $scope.plan.id
                id: $scope.item.id
                title: $scope.item_title
                details: $scope.item_details
                tags: $scope.tags
                item_elements: item_elements
            item.$promise.then () ->
                $('#addItemModal').modal "hide"

    $scope.buttonMessage = () ->
        if $scope.item != null
            "Edit"
        else
            "Add"

    $scope.item = null
    initModal()
]
