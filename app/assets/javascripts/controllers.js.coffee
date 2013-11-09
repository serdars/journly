xplanControllers = angular.module "xplanControllers", [ ]
    
xplanControllers.controller "itemListController", [ '$scope', '$rootScope', 'XplanData', ($scope, $rootScope, XplanData) ->
    $scope.items = XplanData.items
    
    $scope.launchItemCreate = () ->
        $rootScope.$broadcast 'item.create'

    $scope.deleteItem = (item) ->
        XplanData.deleteItem item

    $scope.editItem = (item) ->
        $rootScope.$broadcast 'item.edit', item
]
    
xplanControllers.controller "itemCreationController", [ '$scope', '$rootScope', '$timeout', 'XplanData',  ($scope, $rootScope, $timeout, XplanData) ->
    $('#addItemModal').modal
        show: false

    $rootScope.$on "item.create", () ->
        $scope.item = null
        $('#addItemModal').modal "show"

    $rootScope.$on "item.edit", (event, item) ->
        $scope.item = item
        $('#addItemModal').modal "show"

    timer = null
    debounce = (fn, delay) ->
        if timer != null
            $timeout.cancel timer
        timer = $timeout fn, delay

    isUrl = (value) ->
        # http://stackoverflow.com/questions/5717093/check-if-a-javascript-string-is-an-url
        pattern = new RegExp '^(https?:\\/\\/)?' +
            '((([a-z\\d]([a-z\\d-]*[a-z\\d])*)\\.)+[a-z]{2,}|' +
            '((\\d{1,3}\\.){3}\\d{1,3}))' +
            '(\\:\\d+)?(\\/[-a-z\\d%_.~+]*)*' +
            '(\\?[;&a-z\\d%_.~+=-]*)?' +
            '(\\#[-a-z\\d_]*)?$','i'
        pattern.test value

    deleteElement = (array, element) ->
        index = array.indexOf element
        array.splice index, 1
    
    addAlert = (alertMessage) -> 
        $scope.alerts.push alertMessage
        $timeout () ->
            deleteElement $scope.alerts, alertMessage
        , 5000

    addBookmark = (value) ->
        addAlert "Added '" + value + "' as a bookmark..."
        $scope.bookmarks.push value

    $scope.removeBookmark = (value) ->
        deleteElement $scope.bookmarks, value

    addTag = (value) ->
        addAlert "Added '" + value + "' as a tag..."
        $scope.tags.push value
        
    $scope.removeTag = (value) ->
        deleteElement $scope.tags, value

    addLocation = (location) ->
        XplanData.info
            type: "location"
            key: location.reference
        .then (response) ->
            $scope.locations.push response.data.info
            addAlert "Added '" + response.data.info.name + "' as a location..."

    $scope.removeLocation = (value) ->
        deleteElement $scope.locations, value

    resetSuggestions = () ->
        $scope.suggestions = [ ]
        $scope.magicValue = ""

    suggestionQueryCount = 0
    getSuggestions = (type, term) ->
        $scope.suggestionCount += 1
        # Get tag suggestions
        suggestionQueryCount += 1
        queryNumber = suggestionQueryCount
        XplanData.suggest
            term: term
            type: type
        .then (response) ->
            $scope.suggestionCount -= 1
            # Since we are executing two queries we are
            # letting the the query number to be  1 higher
            # than overall query count
            if queryNumber >= suggestionQueryCount - 1
                angular.forEach response.data.suggestions, (suggestion) ->
                    suggestion.message = "Add " + suggestion.type + ": " + suggestion.value
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
            else
                # Otherwise get suggestions from the server
                $scope.suggestions = [ ]
                getSuggestions "tag", $scope.magicValue
                getSuggestions "location", $scope.magicValue
        , 500

    $scope.suggested = (suggestion) ->
        resetSuggestions()
        if suggestion.type == "tag"
            addTag suggestion.value
        else if suggestion.type == "location"
            addLocation suggestion
    
    $scope.submitItem = () ->
        if $scope.item == null
            XplanData.createItem
                title: $scope.item_title
                details: $scope.item_details
        else
            XplanData.editItem $scope.item,
                title: $scope.item_title
                details: $scope.item_details

    $scope.buttonMessage = () ->
        if $scope.item != null
            "Edit"
        else
            "Add"

    $scope.bookmarks = [ ]
    $scope.alerts = [ ]
    $scope.tags = [ ]
    $scope.locations = [ ]
    $scope.suggestions = [ ]
    $scope.suggestionCount = 0
]
