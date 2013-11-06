xpTagDirective = angular.module 'xpTagDirective', [ ]

xpTagDirective.directive 'xpTag', ($templateCache) ->
    {
        restrict: 'E'
        transclude: true
        scope:
            remove: '&onRemove'
        template: $templateCache.get 'xp-tag.html'
    }
