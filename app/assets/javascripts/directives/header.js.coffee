headerDirective = angular.module 'headerDirective', [ ]

headerDirective.directive 'header', [ 'XplanSession', '$state', (XplanSession, $state) ->
    {
        restrict: 'E'
        transclude: true
        scope: { }
        templateUrl: 'directives/header.html'
        controller: ($scope) ->
            $scope.logoutUser = () ->
                XplanSession.logout().then () ->
                    $state.transitionTo "login"
                , () ->
                    alert "We can not log you out on this computer right now. Please try again in a few moments."
            return
    }
]
