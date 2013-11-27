xpTagDirective = angular.module 'xpTagDirective', [ ]

xpTagDirective.directive 'xpTag', ($templateCache) ->
    {
        restrict: 'E'
        transclude: true
        scope:
            remove: '&onRemove'
        templateUrl: 'directives/xpTag.html'
    }
