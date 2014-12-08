journlyWelcomeController = angular.module "journlyWelcomeController", [ ]

journlyWelcomeController.controller "welcomeController", [ '$scope', '$rootScope', '$timeout', '$state',  ($scope, $rootScope, $timeout, $state) ->
    $scope.goToSurvey = () ->
        $state.transitionTo "survey"

    $scope.goToLogin = () ->
        $state.transitionTo "login"
]
