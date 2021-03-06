journlyApp = angular.module "journlyApp", [ 'journlyControllers', 'journlyServices', 'suggestionListDirective', 'xpTagDirective', 'headerDirective', 'AngularGM', 'ui.router' ]

# Directive eat-click to do preventDefault() links when needed
journlyApp.directive 'eatClick', () ->
    (scope, element, attrs) ->
        $(element).click (event) ->
            event.preventDefault();

journlyApp.directive 'onFinishRender', ($timeout) ->
    {
        restrict: 'A'
        link: (scope, element, attr) ->
            if scope.$last == true
                scope.$evalAsync attr.onFinishRender
    }

# Make sure csrf tokens are included in AJAX calls            
journlyApp.config [ "$httpProvider", (provider) ->
    provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr 'content'
]

journlyApp.config [ '$stateProvider', '$urlRouterProvider', ($stateProvider, $urlRouterProvider) ->
    $urlRouterProvider.otherwise "/welcome"
    
    $stateProvider
        .state 'survey',
            url: "/survey"
            views:
                main:
                    templateUrl: "survey.html"
                    controller: "surveyController"
        .state 'welcome',
            url: "/welcome"
            views:
                main:
                    templateUrl: "welcome.html"
                    controller: "welcomeController"
        .state 'login',
            url: "/login?target"
            resolve:
                currentUser: (JournlySession) ->
                    JournlySession.requestCurrentUser()
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
                    resolve:
                        currentUser: ['JournlySession', (JournlySession) ->
                            JournlySession.requestCurrentUser()
                        ]
                creation:
                    templateUrl: 'plans/creationModal.html'
                    controller: "planCreationController"
        .state 'items',
            url: "/plans/:planId"
            views:
                main:
                    templateUrl: "plans/show.html"
                    controller: "itemListController"
                    resolve:
                        currentUser: ['JournlySession', (JournlySession) ->
                            JournlySession.requestCurrentUser()
                        ]
                creation:
                    templateUrl: 'items/creationModal.html'
                    controller: "itemCreationController"
]

journlyApp.controller "appController", [ '$scope', 'JournlySession', ($scope, JournlySession) ->
    JournlySession.requestCurrentUser()
]

$(document).ready () ->
    script = document.createElement "script"
    script.type = "text/javascript"
    script.src = "https://maps.googleapis.com/maps/api/js?v=3.exp&sensor=false&callback=onGoogleReady"
    document.body.appendChild script

window.onGoogleReady = () ->
    angular.bootstrap document, [ 'journlyApp' ]
