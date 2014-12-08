journlyPlanCreationController = angular.module "journlyPlanCreationController", [ ]

journlyPlanCreationController.controller "planCreationController", [ '$scope', '$rootScope', '$timeout', 'JournlyPlan',  ($scope, $rootScope, $timeout, JournlyPlan) ->
    initModal = () ->
        if $scope.plan != null
            $scope.plan_name = angular.copy $scope.plan.name
            $scope.plan_note = angular.copy $scope.plan.note
            $scope.destinationReference = angular.copy $scope.plan.destination_reference
        else
            $scope.plan_name = ""
            $scope.plan_note = ""
            $scope.destinationReference = null

    $('#addPlanModal').modal
        show: false
    $('#addPlanModal').on "hidden.bs.modal", () ->
        initModal()

    $rootScope.$on "plan.create", () ->
        $scope.plan = null
        initModal()
        $('#addPlanModal').modal "show"

    $rootScope.$on "plan.edit", (event, plan) ->
        $scope.plan = plan
        initModal()
        $('#addPlanModal').modal "show"
        $('input.plan-destination').val(plan.destination.name)

    $scope.buttonMessage = () ->
        if $scope.plan != null
            "Edit"
        else
            "Add"

    $('input.plan-destination').typeahead
        name: 'destinations'
        remote:
            url: '/suggest?type=destination&term=%QUERY'
            filter: (parsedResponse) ->
                destinationData = [ ]
                angular.forEach parsedResponse.suggestions, (destination) ->
                    destinationData.push
                        value: destination.value
                        tokens: destination.value.split(" ")
                        reference: destination.reference

                if destinationData.length == 0
                    destinationData.push
                        value: "Can not find a destination"
                        tokens: [ ]
                        reference: null
                destinationData

    $('input.plan-destination').on "typeahead:selected", (event, destination) ->
        if destination.reference != null
            $scope.destinationReference = destination.reference
        else
            console.log "TODO: Error time"

    $scope.submitPlan = () ->
        # TODO: Need to do some validation here...
        if $scope.plan == null
            plan = JournlyPlan.createPlan
                name: $scope.plan_name
                note: $scope.plan_note
                destination_reference: $scope.destinationReference
        else
            plan = JournlyPlan.editPlan $scope.plan,
                id: $scope.plan.id
                name: $scope.plan_name
                note: $scope.plan_note
                destination_reference: $scope.destinationReference

        plan.$promise.then () ->
            $('#addPlanModal').modal "hide"

    $scope.plan = null
    initModal()
]
