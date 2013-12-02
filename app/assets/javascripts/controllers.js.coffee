xplanControllers = angular.module "xplanControllers", [ ]

xplanControllers.controller "loginController", [ '$scope', '$rootScope', '$timeout', 'XplanPlan', '$stateParams', ($scope, $rootScope, $timeout, XplanPlan, $stateParams) ->
    # Nothing for now.
]

xplanControllers.controller "itemListController", [ '$scope', '$rootScope', '$timeout', 'XplanItem', 'XplanPlan', 'angulargmContainer', '$stateParams', ($scope, $rootScope, $timeout, XplanItem, XplanPlan, angulargmContainer, $stateParams) ->
    $scope.plan_id = $stateParams.planId
    $scope.plan = XplanPlan.getPlan($scope.plan_id)
    $scope.plan.$promise.then () ->
        locationExists = false
        angular.forEach $scope.items, (item) ->
            angular.forEach item.locations, (location) ->
                locationExists = true
        if !locationExists
            $scope.map.setOptions
                center: new google.maps.LatLng($scope.plan.destination.geometry.lat,$scope.plan.destination.geometry.lng)
                zoom: 8
                
    $scope.items = XplanItem.getItems $scope.plan_id

    $scope.launchItemCreate = () ->
        $rootScope.$broadcast 'item.create', $scope.plan

    initFilterSearch = () ->
        $('input.filter-search').typeahead
            name: 'tags'
            remote:
                url: '/suggest?type=tag&term=%QUERY'
                filter: (parsedResponse) ->
                    tagData = [ ]
                    angular.forEach parsedResponse.suggestions, (tag) ->
                        if tag.id && tag.name
                            tagData.push
                                value: tag.name
                                tokens: tag.name.split(" ")

                    if tagData.length == 0
                        tagData.push
                            value: "No tags..."
                            tokens: [ ]
                    tagData

        $('input.filter-search').on "typeahead:selected", (event, tag) ->
            if tag.value != "No tags..."
                $rootScope.$broadcast 'filter.term', tag.value
            else
                $rootScope.$broadcast 'filter.term', ""

        filterTimer = null
        debounce = (fn, delay) ->
            if filterTimer != null
                $timeout.cancel timer
            filterTimer = $timeout fn, delay

        $('input.filter-search').keydown () ->
            debounce () ->
                if $('input.filter-search').val() == ""
                    $rootScope.$broadcast 'filter.term', ""
            , 100

    $scope.deleteItem = (event, item) ->
        event.stopPropagation()
        if confirm("Are you sure you want to delete this item?")
            XplanItem.deleteItem item

    $scope.editItem = (event, item) ->
        event.stopPropagation()
        $rootScope.$broadcast 'item.edit', item, $scope.plan

    getElementsByType = (item, type) ->
        elements = [ ]
        angular.forEach item.item_elements, (element) ->
            if element.element_type == type
                elements.push element
        elements

    $scope.hostname = (url) ->
        parts = url.split "/"
        if parts[0] != "http:" && parts[0] != "https:"
            parts[0]
        else
            parts[2]

    $scope.getDirectionsLink = (location) ->
        param = location.address.split(" ").join("+")
        "https://maps.google.com/maps?daddr=" + param
        
    $scope.markerEvent = (event, itemId) ->
        item = null
        angular.forEach $scope.items, (i) ->
            if i.id == itemId
                item = i
        switch event
            when "highlight"
                $scope.highlightItem(item)
            when "unhighlight"
                $scope.unhighlightItem(item)
            when "select"
                $scope.selectItem(item)

    timer = null
    debounce = (fn, delay) ->
        if timer != null
            $timeout.cancel timer
        timer = $timeout fn, delay

    $scope.markerHighlight = (itemId) ->
        if timer != null
            $timeout.cancel timer
            timer = null
        $scope.markerEvent "highlight", itemId

    $scope.markerUnhighlight = (itemId) ->
        debounce () ->
            $scope.markerEvent "unhighlight", itemId
        , 500

    $scope.setupInfoWindowEvents = (itemId) ->
        $(".location-info-window").mouseenter (event) ->
            if timer != null
                $timeout.cancel timer
                timer = null
            $scope.markerEvent "highlight", itemId

        $(".location-info-window").mouseleave (event) ->
            debounce () ->
                $scope.markerEvent "unhighlight", itemId
            , 500

        return

    initTooltips = () ->
        $(".item-action").tooltip {container: "body"}
        return

    $scope.postRender = () ->
        initFilterSearch()
        initTooltips()

    $scope.$on 'gmMarkersUpdated', (event, objects) ->
        locationExists = false
        latlngBounds = new google.maps.LatLngBounds

        angular.forEach $scope.items, (item) ->
            angular.forEach item.locations, (location) ->
                locationExists = true
                latlngBounds.extend new google.maps.LatLng(location.geometry.lat, location.geometry.lng)
        if locationExists
            $scope.map.fitBounds latlngBounds
            if $scope.map.getZoom() > 14
                $scope.map.setZoom 14

    $(".map-canvas").height ($(window).height() - 51)
    $(".list-canvas").css "max-height", ($(window).height() - 51)
    $(window).resize () ->
        $(".list-canvas").css "max-height", ($(window).height() - 51)
        $(".map-canvas").height ($(window).height() - 51)
        google.maps.event.trigger $scope.map, 'resize'

    highlightedItem = null
    $scope.highlightItem = (item) ->
        if highlightedItem != null
            $scope.unhighlightItem highlightedItem
        item.highlighted = true
        highlightedItem = item
        angular.forEach item.locations, (location) ->
            location.$infoWindow.open $scope.map, location.$marker

    $scope.unhighlightItem = (item) ->
        item.highlighted = false
        unless item.selected
            angular.forEach item.locations, (location) ->
                location.$infoWindow.close()
        highlightedItem = null

    selectedItem = null
    unselectItem = (item) ->
        item.selected = false
        selectedItem = null
        angular.forEach item.locations, (location) ->
            location.$infoWindow.close()

    $scope.selectItem = (item) ->
        if item.selected
            unselectItem item
        else
            if selectedItem != null
                unselectItem selectedItem
            item.selected = true
            selectedItem = item
            angular.forEach item.locations, (location) ->
                location.$infoWindow.open $scope.map, location.$marker

    $scope.filterTerm = ""
    $scope.$on 'filter.term', (event, filterTerm) ->
        $scope.filterTerm = filterTerm
        $scope.$digest()

    $scope.filterByTag = (item) ->
        if $scope.filterTerm && $scope.filterTerm != ""
            tagFound = false
            angular.forEach item.tags, (tag) ->
                if tag.name == $scope.filterTerm
                    tagFound = true
            return tagFound
        else
            return true

    google.maps.visualRefresh = true;
    $scope.mapId = 'PlanMap'
    angulargmContainer.getMapPromise($scope.mapId).then (gmap, other) ->
        $scope.map = gmap

]

xplanControllers.controller "itemCreationController", [ '$scope', '$rootScope', '$timeout', 'XplanItem',  ($scope, $rootScope, $timeout, XplanItem) ->
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

xplanControllers.controller "planListController", [ '$scope', '$rootScope', '$timeout', 'XplanPlan', '$location', 'angulargmContainer', ($scope, $rootScope, $timeout, XplanPlan, $location, angulargmContainer) ->
    $scope.plans = XplanPlan.plans

    $scope.launchPlanCreate = () ->
        $rootScope.$broadcast 'plan.create'
        
    initTooltips = () ->
        $(".item-action").tooltip {container: "body"}
        return

    initMaps = () ->
        angular.forEach $scope.plans, (plan) ->
            map = angulargmContainer.getMap("planSummaryMap_" + plan.id)
            map.setOptions
                center: new google.maps.LatLng(plan.destination.geometry.lat, plan.destination.geometry.lng)
                draggable: false
                # mapTypeId: google.maps.MapTypeId.HYBRID
                scrollwheel: false
                disableDefaultUI: true
                zoom: 10

    $scope.initViews = () ->
        initTooltips()
        initMaps()

    highlightedPlan = null
    $scope.highlightPlan = (plan) ->
        if highlightedPlan != null
            $scope.unhighlightPlan highlightedPlan
        plan.highlighted = true
        highlightedPlan = plan

    $scope.unhighlightPlan = (plan) ->
        plan.highlighted = false
        highlightedPlan = null

    $scope.deletePlan = (event, plan) ->
        event.stopPropagation()
        if confirm("Are you sure you want to delete this plan?")
            XplanPlan.deletePlan plan

    $scope.editPlan = (event, plan) ->
        event.stopPropagation()
        $rootScope.$broadcast 'plan.edit', plan

    $scope.showPlan = (planId) ->
        $location.path "/plans/" + planId

]

xplanControllers.controller "planCreationController", [ '$scope', '$rootScope', '$timeout', 'XplanPlan',  ($scope, $rootScope, $timeout, XplanPlan) ->
    initModal = () ->
        if $scope.plan != null
            $scope.plan_name = angular.copy $scope.plan.name
            $scope.plan_note = angular.copy $scope.plan.note
            $scope.destinationReference = angular.copy $scope.plan.destination_reference
        else
            $scope.plan_name = ""
            $scope.plan_note = ""
            $scope.destinationReference = null

    $('#addPlanModal').modal
        show: false
    $('#addPlanModal').on "hidden.bs.modal", () ->
        initModal()

    $rootScope.$on "plan.create", () ->
        $scope.plan = null
        initModal()
        $('#addPlanModal').modal "show"

    $rootScope.$on "plan.edit", (event, plan) ->
        $scope.plan = plan
        initModal()
        $('#addPlanModal').modal "show"
        $('input.plan-destination').val(plan.destination.name)

    $scope.buttonMessage = () ->
        if $scope.plan != null
            "Edit"
        else
            "Add"

    $('input.plan-destination').typeahead
        name: 'destinations'
        remote:
            url: '/suggest?type=destination&term=%QUERY'
            filter: (parsedResponse) ->
                destinationData = [ ]
                angular.forEach parsedResponse.suggestions, (destination) ->
                    destinationData.push
                        value: destination.value
                        tokens: destination.value.split(" ")
                        reference: destination.reference

                if destinationData.length == 0
                    destinationData.push
                        value: "Can not find a destination"
                        tokens: [ ]
                        reference: null
                destinationData

    $('input.plan-destination').on "typeahead:selected", (event, destination) ->
        if destination.reference != null
            $scope.destinationReference = destination.reference
        else
            console.log "TODO: Error time"

    $scope.submitPlan = () ->
        # TODO: Need to do some validation here...
        if $scope.plan == null
            plan = XplanPlan.createPlan
                name: $scope.plan_name
                note: $scope.plan_note
                destination_reference: $scope.destinationReference
        else
            plan = XplanPlan.editPlan $scope.plan,
                id: $scope.plan.id
                name: $scope.plan_name
                note: $scope.plan_note
                destination_reference: $scope.destinationReference

        plan.$promise.then () ->
            $('#addPlanModal').modal "hide"

    $scope.plan = null
    initModal()
]
