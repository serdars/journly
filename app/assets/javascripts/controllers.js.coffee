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
    initModal = () ->
        $scope.alerts = [ ]
        $scope.suggestions = [ ]
        $scope.yelpInfos = [ ]
        $scope.suggestionCount = 0
        if $scope.item != null
            $scope.item_title = $scope.item.title
            $scope.item_details = $scope.item.details
            $scope.tags = $scope.item.tags
            $scope.locations = [ ]
            angular.forEach $scope.item.item_elements, (element) ->
                switch element.element_type
                    when "google_place"
                        $scope.locations.push element
                    when "bookmark"
                        $scope.bookmarks.push element
                    else
                        console.log "Unknown element type: " + element.element_type
        else
            $scope.item_title = ""
            $scope.item_details = ""
            $scope.tags = [ ]
            $scope.locations = [ ]
            $scope.bookmarks = [ ]

    $('#addItemModal').modal
        show: false
    $('#addItemModal').on "hidden.bs.modal", () ->
        initModal()
        
    $rootScope.$on "item.create", () ->
        $scope.item = null
        initModal()
        $('#addItemModal').modal "show"

    $rootScope.$on "item.edit", (event, item) ->
        $scope.item = item
        initModal()
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
        $scope.bookmarks.push
            element_type: "bookmark"
            name: value
        addAlert "Added '" + value + "' as a bookmark..."
        $scope.processing_message = "Looking up " + value + " ..."
        $scope.suggestionCount += 1
        XplanData.info
            type: "bookmark"
            key: value
        .then (response) ->
            $scope.suggestionCount -= 1
            angular.forEach response.data.info, (info) ->
                if info.type == "name"
                    $scope.item_title = info.value
                    addAlert "Added '" + info.value + "' as the title..."
                if info.type == "yelp"
                    $scope.yelpInfos.push info.value
                    addAlert "Added Yelp info for '" + info.value.name + "'"
                    $scope.item_title = info.value.name
                    addAlert "Added '" + info.value.name + "' as the title..."
            
    $scope.removeBookmark = (value) ->
        deleteElement $scope.bookmarks, value

    addTag = (tag) ->
        addAlert "Added '" + tag.name + "' as a tag..."
        $scope.tags.push tag
        
    $scope.removeTag = (tag) ->
        deleteElement $scope.tags, tag

    addLocation = (location) ->
        $scope.processing_message = "Looking up info for " + location.value + " ..."
        $scope.suggestionCount += 1
        XplanData.info
            type: "google_place"
            key: location.reference
        .then (response) ->
            $scope.suggestionCount -= 1
            $scope.locations.push response.data.info
            addAlert "Added '" + response.data.info.name + "' as a location..."

    $scope.removeLocation = (value) ->
        deleteElement $scope.locations, value

    $scope.removeYelpInfo = (value) ->
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
        XplanData.suggest
            term: term
            type: type
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
                        suggestion.message = "Add tag: " + suggestion_data.name
                    else if response.data.suggestion_type == "google_place"
                        suggestion.message = "Add location: " + suggestion_data.value
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
        item_elements = [ ]
        angular.forEach $scope.locations, (location) ->
            item_elements.push location
        angular.forEach $scope.bookmarks, (location) ->
            item_elements.push location
        if $scope.item == null
            item = XplanData.createItem
                title: $scope.item_title
                details: $scope.item_details
                tags: $scope.tags
                item_elements: item_elements
            item.$promise.then () ->
                $('#addItemModal').modal "hide"                
        else
            item = XplanData.editItem $scope.item,
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
