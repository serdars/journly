xplanServices = angular.module "xplanServices", [ 'ngResource' ]

xplanServices.factory 'XplanPlan', [ '$resource', '$http',
    ($resource, $http) ->
        # This is mostly copy paste from XplanItem
        transform = (planData) ->
            planData

        transformPlan = (data, headersGetter) ->
            plans = JSON.parse(data)
            if plans instanceof Array
                angular.forEach plans, (planData) ->
                    transform planData

            else
                transform plans

            plans

        Plan = $resource '/plans/:planId.json', {
            planId: '@id'
        }, {
            get: {method:'GET', params:{planId:'@id'}, transformResponse:transformPlan, isArray:true},
            delete: {method:'DELETE', params:{planId:'@id'}}
            save: {method:'POST', params:{planId:'@id'}, transformResponse:transformPlan}
        }

        dataService = { }

        dataService.plans = Plan.get {},
            isArray: true

        dataService.createPlan = (params) ->
            Plan.save params, (plan) ->
                dataService.plans.push plan
            , () ->
                console.log "Failed to CREATE"

        dataService.editPlan = (plan, params) ->
            Plan.save params, (newPlan) ->
                angular.forEach newPlan, (value, key) ->
                    if key.substring(0, 1) != "$"
                        this[key] = value
                , plan
            , () ->
                console.log "Failed to EDIT"

        dataService.deletePlan = (plan) ->
            plan.$delete()
            .then () ->
                # Delete succeeded
                index = dataService.plans.indexOf plan
                dataService.plans.splice index, 1
            , () ->
                # Delete failed
                console.log "Failed to DELETE"

        dataService
]

xplanServices.factory 'XplanItem', [ '$resource', '$http',
    ($resource, $http) ->
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

        dataService.getItems = (planId) ->
            items = PlanItem.get
                plan_id: planId

            dataService.items[planId] = items
            dataService.items[planId]

        dataService.createItem = (params) ->
            PlanItem.save params, (item) ->
                dataService.items[params.plan_id].push item
            , () ->
                console.log "Failed to CREATE"

        dataService.editItem = (item, params) ->
            PlanItem.save params, (newItem) ->
                angular.forEach newItem, (value, key) ->
                    if key == "locations"
                        # Locations require special attention unfotunately
                        angular.forEach value, (updatedLocation) ->
                            # For the original location
                            originalLocation = null
                            angular.forEach item.locations, (location) ->
                                if location.id == updatedLocation.id
                                    originalLocation = location
                            if originalLocation == null
                                item.locations.push updatedLocation
                            else
                                angular.forEach updatedLocation, (value, key) ->
                                    if key.substring(0, 1) != "$"
                                        originalLocation[key] = value
                    else if key.substring(0, 1) != "$"
                        this[key] = value
                , item
            , () ->
                console.log "Failed to EDIT"

        dataService.deleteItem = (item) ->
            item.$delete()
            .then () ->
                # Delete succeeded
                index = dataService.items[item.plan_id].indexOf item
                dataService.items.splice index, 1
            , () ->
                # Delete failed
                console.log "Failed to DELETE"

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
