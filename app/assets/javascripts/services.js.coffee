xplanServices = angular.module "xplanServices", [ 'ngResource' ]

xplanServices.factory 'XplanData', [ '$resource', '$http',
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

        dataService.items = PlanItem.get {},
            isArray: true
        
        dataService.createItem = (params) ->
            PlanItem.save params, (item) ->
                dataService.items.push item
            , () ->
                console.log "Failed to CREATE"

        dataService.editItem = (item, params) ->
            PlanItem.save params, (newItem) ->
                angular.forEach newItem, (value, key) ->
                    if key.substring(0, 1) != "$"
                        this[key] = value
                , item
            , () ->
                console.log "Failed to EDIT"

        dataService.deleteItem = (item) ->
            item.$delete()
            .then () ->
                # Delete succeeded
                index = dataService.items.indexOf item
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
