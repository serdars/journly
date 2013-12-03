xplanPlanService = angular.module "xplanPlanService", [ 'ngResource' ]

xplanPlanService.factory 'XplanPlan', [ '$resource', '$http', '$rootScope',
    ($resource, $http, $rootScope) ->
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

        $rootScope.$on "user.logout", () ->
            dataService.plans = [ ]

        $rootScope.$on "user.login", () ->
            dataService.plans = Plan.query {}
            
        dataService.getPlan = (planId) ->
            Plan.get
                planId: planId

        dataService.createPlan = (params) ->
            Plan.save params, (plan) ->
                dataService.plans.push plan
            , () ->
                console.log "TODO: Failed to CREATE"

        dataService.editPlan = (plan, params) ->
            Plan.save params, (newPlan) ->
                angular.forEach newPlan, (value, key) ->
                    if key.substring(0, 1) != "$"
                        this[key] = value
                , plan
            , () ->
                console.log "TODO: Failed to EDIT"

        dataService.deletePlan = (plan) ->
            plan.$delete()
            .then () ->
                # Delete succeeded
                index = dataService.plans.indexOf plan
                dataService.plans.splice index, 1
            , () ->
                # Delete failed
                console.log "TODO: Failed to DELETE"

        dataService
]
