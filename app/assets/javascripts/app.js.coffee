xplanApp = angular.module "xplanApp", [ 'xplanControllers', 'xplanServices', 'suggestionListDirective', 'xpTagDirective', 'headerDirective', 'AngularGM', 'ui.router' ]

# Directive eat-click to do preventDefault() links when needed
xplanApp.directive 'eatClick', () ->
    (scope, element, attrs) ->
        $(element).click (event) ->
            event.preventDefault();

xplanApp.directive 'onFinishRender', ($timeout) ->
    {
        restrict: 'A'
        link: (scope, element, attr) ->
            if scope.$last == true
                scope.$evalAsync attr.onFinishRender
    }

# Make sure csrf tokens are included in AJAX calls            
xplanApp.config [ "$httpProvider", (provider) ->
    provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr 'content'
]

xplanApp.config [ '$stateProvider', '$urlRouterProvider', ($stateProvider, $urlRouterProvider) ->
    $urlRouterProvider.otherwise "/login"

    # Check if the user is authorized in all pages
    $urlRouterProvider.rule ($injector, $location) ->
        XplanSession = $injector.get "XplanSession"
        path = $location.path()
        search = $location.search()
        if path != '/login'
            # TODO: user requestCurrentUser() instead.
            # TODO: this is totally broken right now... Peace out...
            if XplanSession.requestCurrentUser() != null
                null
            else
                '/login?target=' + path
        else
            null
    
    $stateProvider
        .state 'login',
            url: "/login?target"
            views:
                main:
                    templateUrl: "login.html"
                    controller: "loginController"
        .state 'plans',
            url: "/plans"
            views:
                main:
                    templateUrl: "plans/index.html"
                    controller: "planListController"
                creation:
                    templateUrl: 'plans/creationModal.html'
                    controller: "planCreationController"
        .state 'items',
            url: "/plans/:planId"
            views:
                main:
                    templateUrl: "plans/show.html"
                    controller: "itemListController"
                creation:
                    templateUrl: 'items/creationModal.html'
                    controller: "itemCreationController"
]

xplanApp.controller "appController", [ '$scope', 'XplanSession', ($scope, XplanSession) ->
    XplanSession.requestCurrentUser()
]

$(document).ready () ->
    script = document.createElement "script"
    script.type = "text/javascript"
    script.src = "https://maps.googleapis.com/maps/api/js?v=3.exp&sensor=false&callback=onGoogleReady"
    document.body.appendChild script

window.onGoogleReady = () ->
    angular.bootstrap document, [ 'xplanApp' ]
