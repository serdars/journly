xplanServices = angular.module "xplanServices", [ 'ngResource' ]

xplanServices.factory 'XplanData', [ '$resource',
    ($resource) ->
        # Resource service we are using to talk to the backend
        PlanItem = $resource '/items/:itemId', {
            itemId: '@id'
        }, {
            get: {method:'GET', params:{itemId:'@id'}, isArray:true}
        }
        
        dataService = { }

        dataService.items = PlanItem.get {},
            isArray: true
        
        dataService.createItem = (params) ->
            item = PlanItem.save params
            dataService.items.push item

        dataService
]
