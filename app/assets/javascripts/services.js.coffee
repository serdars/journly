xplanServices = angular.module "xplanServices", [ 'ngResource' ]

xplanServices.factory 'XplanData', [ '$resource',
    ($resource) ->
        # Resource service we are using to talk to the backend
        PlanItem = $resource '/items/:itemId.json', {
            itemId: '@id'
        }, {
            get: {method:'GET', params:{itemId:'@id'}, isArray:true},
            delete: {method:'DELETE', params:{itemId:'@id'}}
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
            changedParams = { }
            objectChanged = false
            angular.forEach params, (value, key) ->
                if item[key] != value
                    objectChanged = true
                    this[key] = value
            , changedParams

            if objectChanged
                PlanItem.save changedParams, (newItem) ->
                    angular.forEach changedParams, (value, key) ->
                        this[key] = value
                    , item
                , () ->
                    console.log "Failed to EDIT"
            else
                console.log "Nothing to EDIT"

        dataService.deleteItem = (item) ->
            item.$delete()
            .then () ->
                # Delete succeeded
                index = dataService.items.indexOf item
                dataService.items.splice index, 1
            , () ->
                # Delete failed
                console.log "Failed to DELETE"

        dataService
]
