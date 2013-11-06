suggestionListDirective = angular.module 'suggestionListDirective', [ ]

suggestionListDirective.directive 'suggestionList', ($templateCache) ->
    {
        restrict: 'E'
        transclude: true
        scope: { }
        template: $templateCache.get 'suggestion-list.html'
        controller: ($scope) ->
            $scope.suggestions = [ ]

            $scope.select = (suggestion) ->
                angular.forEach $scope.suggestions, (suggestion) ->
                    suggestion.selected = false
                        
                suggestion.selected = true

            this.addSuggestion = (suggestion) ->
                if $scope.suggestions.length == 0
                    suggestion.select()

                $scope.suggestions.push suggestion

    }

suggestionListDirective.directive 'suggestionItem', ($templateCache) ->
    {
        require: "^suggestionList"
        restrict: "E"
        transclude: true
        scope:
            title: '@'
        link: (scope, element, attrs, suggestionListCtrl) ->
            suggestionListCtrl.addSuggestion scope
        template: $templateCache.get 'suggestion-item.html'
    }
