headerDirective = angular.module 'headerDirective', [ ]

headerDirective.directive 'header', () ->
    {
        restrict: 'E'
        transclude: true
        scope: { }
        templateUrl: 'directives/header.html'
        controller: ($scope) ->
            return
    }
