suggestionListDirective = angular.module 'suggestionListDirective', [ ]

suggestionListDirective.directive 'suggestionList', ($templateCache) ->
    {
        restrict: 'E'
        transclude: true
        scope: { }
        template: $templateCache.get 'suggestion-list.html'
        controller: ($scope) ->
            $scope.suggestions = [ ]

            this.highlightSuggestion = (suggestion) ->
                angular.forEach $scope.suggestions, (suggestion) ->
                    suggestion.highlighted = false
                        
                suggestion.highlighted = true

            this.addSuggestion = (suggestion) ->
                if $scope.suggestions.length == 0
                    suggestion.highlight()

                $scope.suggestions.push suggestion

    }

suggestionListDirective.directive 'suggestionItem', ($templateCache) ->
    {
        require: "^suggestionList"
        restrict: "E"
        transclude: true
        scope:
            select: '&onSelect'
        link: ($scope, element, attrs, suggestionListCtrl) ->
            $scope.highlighted = false
            
            $scope.highlight = () ->
                suggestionListCtrl.highlightSuggestion $scope

            suggestionListCtrl.addSuggestion $scope
        template: $templateCache.get 'suggestion-item.html'
    }
