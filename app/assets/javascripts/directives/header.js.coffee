headerDirective = angular.module 'headerDirective', [ ]

headerDirective.directive 'header', [ 'JournlySession', '$state', (JournlySession, $state) ->
    {
        restrict: 'E'
        transclude: true
        scope: { }
        templateUrl: 'directives/header.html'
        controller: ($scope) ->
            currentUser = JournlySession.requestCurrentUser().then (user) ->
                $scope.user = user
            
            $scope.logoutUser = () ->
                JournlySession.logout().then () ->
                    $state.transitionTo "login"
                , () ->
                    alert "We can not log you out on this computer right now. Please try again in a few moments."
            return
    }
]
