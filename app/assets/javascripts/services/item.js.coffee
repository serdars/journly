journlyItemService = angular.module "journlyItemService", [ 'ngResource' ]

journlyItemService.factory 'JournlyItem', [ '$resource', '$http', '$rootScope',
    ($resource, $http, $rootScope) ->
        transform = (itemData) ->
            itemData.yelpInfos = [ ]
            itemData.bookmarks = [ ]
            itemData.locations = [ ]

            angular.forEach itemData.item_elements, (info) ->
                switch info.element_type
                    when "google_place"
                        # (sadpanda)
                        # Need this to tie the marker events to related item
                        info.item_id = itemData.id
                        itemData.locations.push info
                    when "bookmark"
                        itemData.bookmarks.push info
                    when "yelp"
                        itemData.yelpInfos.push info
                    else
                        console.log "Unknown element type: " + info.element_type

            itemData

        transformItem = (data, headersGetter) ->
            items = JSON.parse(data)
            if items instanceof Array
                angular.forEach items, (itemData) ->
                    transform itemData

            else
                transform items

            items


        # Resource service we are using to talk to the backend
        PlanItem = $resource '/items/:itemId.json', {
            itemId: '@id'
        }, {
            get: {method:'GET', params:{itemId:'@id'}, transformResponse:transformItem, isArray:true},
            delete: {method:'DELETE', params:{itemId:'@id'}}
            save: {method:'POST', params:{itemId:'@id'}, transformResponse:transformItem}
        }

        dataService = { }
        dataService.items = { }

        $rootScope.$on "user.logout", () ->
            dataService.items = { }

        dataService.getItems = (planId) ->
            items = PlanItem.get
                plan_id: planId

            dataService.items[planId] = items
            dataService.items[planId]

        dataService.createItem = (params) ->
            PlanItem.save params, (item) ->
                dataService.items[params.plan_id].push item
            , () ->
                console.log "TODO: Failed to CREATE"

        dataService.editItem = (item, params) ->
            PlanItem.save params, (newItem) ->
                angular.forEach newItem, (value, key) ->
                    if key == "locations"
                        # Locations require special attention unfortunately
                        # And worse we are assuming they arrive sorted by id
                        index = 0
                        loop
                            if value[index] && item.locations[index]
                                if value[index].id > item.locations[index].id
                                    # Original location is removed
                                    item.locations.splice index, 1
                                    # No need to bump up the index because we've deleted one element
                                else if value[index].id == item.locations[index].id
                                    # Original Element might be updated
                                    angular.forEach value[index], (value, key) ->
                                        if key.substring(0, 1) != "$"
                                            item.locations[index][key] = value
                                    index += 1
                                else
                                    # Means we've added a new location with a lower id. Shouldn't happen now
                                    console.log "How come you add a location with a lower id... Raising eyebrow..."
                                    index += 1
                            else if item.locations[index]
                                # We only have the original location. We need to remove it
                                item.locations.splice index, 1
                                # No need to bump up
                            else if value[index]
                                # We have a new location. We need to add it
                                item.locations.push value[index]
                                index += 1
                            else
                                # Nothing left. Let's exit
                                break
                    else if key.substring(0, 1) != "$"
                        this[key] = value
                , item
            , () ->
                console.log "TODO: Failed to EDIT"

        dataService.deleteItem = (item) ->
            item.$delete()
            .then () ->
                # Delete succeeded
                index = dataService.items[item.plan_id].indexOf item
                dataService.items[item.plan_id].splice index, 1
            , () ->
                # Delete failed
                console.log "TODO: Failed to DELETE"

        dataService.suggest = (params) ->
            $http
                method: 'GET'
                url: "/suggest.json"
                params: params

        dataService.info = (params) ->
            $http
                method: 'GET'
                url: "/info.json"
                params: params

        dataService
]

