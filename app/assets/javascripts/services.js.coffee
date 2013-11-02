xplanServices = angular.module "xplanServices", [ 'ngResource' ]

xplanServices.factory 'XplanData', [ '$resource',
    ($resource) ->
        # Resource service we are using to talk to the backend
        PlanItem = $resource '/items/:itemId', {
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
            
        dataService.deleteItem = (item) ->
            item.$delete () ->
                # Delete succeeded
                index = dataService.items.indexOf item
                dataService.items.splice index, 1
            , () ->
                # Delete failed
                console.log "Failed to DELETE"

        dataService
]
