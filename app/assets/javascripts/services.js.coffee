xplanServices = angular.module "xplanServices", [ 'ngResource' ]

xplanServices.factory 'XplanSession', [ '$http', '$location', ($http, $location) ->
    sessionService = { }

    currentUser = null

    isAuthenticated = () ->
        !!currentUser

    sessionService.login = (email, password) ->

    sessionService.logout = () ->

    sessionService.register = (email, password, confirmPassword) ->

    sessionService.currentUser = () ->
        null

    sessionService
]

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
            get: {method:'GET', params:{planId:'@id'}, transformResponse:transformPlan},
            query: {method:'GET', params:{planId:'@id'}, transformResponse:transformPlan, isArray:true},
            delete: {method:'DELETE', params:{planId:'@id'}}
            save: {method:'POST', params:{planId:'@id'}, transformResponse:transformPlan}
        }

        dataService = { }

        dataService.plans = Plan.query {}

        dataService.getPlan = (planId) ->
            Plan.get
                planId: planId

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
                console.log "Failed to EDIT"

        dataService.deleteItem = (item) ->
            item.$delete()
            .then () ->
                # Delete succeeded
                index = dataService.items[item.plan_id].indexOf item
                dataService.items[item.plan_id].splice index, 1
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
