xplanApp = angular.module "xplanApp", [ 'xplanControllers', 'xplanServices', 'suggestionListDirective', 'xpTagDirective' ]

# Directive eat-click to do preventDefault() links when needed
xplanApp.directive 'eatClick', () ->
    (scope, element, attrs) ->
        $(element).click (event) ->
            event.preventDefault();

# Make sure csrf tokens are included in AJAX calls            
xplanApp.config [ "$httpProvider", (provider) ->
    provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr 'content'
    ]

xplanApp.controller "appController", ($scope) ->
    # Nothing for now.
