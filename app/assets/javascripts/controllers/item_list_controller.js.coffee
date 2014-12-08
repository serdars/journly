journlyItemListController = angular.module "journlyItemListController", [ ]

journlyItemListController.controller "itemListController", [ '$scope', '$rootScope', '$timeout', 'JournlyItem', 'JournlyPlan', 'angulargmContainer', '$stateParams', 'currentUser', '$state', ($scope, $rootScope, $timeout, JournlyItem, JournlyPlan, angulargmContainer, $stateParams, currentUser, $state) ->
    if currentUser == null
        $state.transitionTo "login",
            target: "plan/" + $stateParams.planId

    $scope.plan_id = $stateParams.planId
    $scope.plan = JournlyPlan.getPlan($scope.plan_id)
    $scope.plan.$promise.then () ->
        locationExists = false
        angular.forEach $scope.items, (item) ->
            angular.forEach item.locations, (location) ->
                locationExists = true
        if !locationExists
            $scope.map.setOptions
                center: new google.maps.LatLng($scope.plan.destination.geometry.lat,$scope.plan.destination.geometry.lng)
                zoom: 8
                
    $scope.items = JournlyItem.getItems $scope.plan_id

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
            JournlyItem.deleteItem item

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
