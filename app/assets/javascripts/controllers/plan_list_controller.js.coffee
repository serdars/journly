xplanPlanListController = angular.module "xplanPlanListController", [ ]

xplanPlanListController.controller "planListController", [ '$scope', '$rootScope', '$timeout', 'XplanPlan', '$location', 'angulargmContainer', 'currentUser', '$state', ($scope, $rootScope, $timeout, XplanPlan, $location, angulargmContainer, currentUser, $state) ->
    if currentUser == null
        $state.transitionTo "login",
            target: "plans"
            
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

