xplanSessionService = angular.module "xplanSessionService", [ 'ngResource' ]

xplanSessionService.factory 'XplanSession', [ '$http', '$location', '$q', '$rootScope', ($http, $location, $q, $rootScope) ->
    sessionService = { }

    sessionService.currentUser = null
    sessionService.isAuthenticated = () ->
        !!sessionService.currentUser

    sessionService.login = (email, password) ->
        responsePromise = $http.post 'users/sign_in.json',
            user:
                email: email
                password: password
                remember_me: true
        responsePromise.success (response) ->
            sessionService.currentUser = response.user
            $http.defaults.headers.common['X-CSRF-Token'] = response.csrfToken
            $rootScope.$broadcast "user.login"
        responsePromise

    sessionService.logout = () ->
        responsePromise = $http.delete 'users/sign_out.json'
        responsePromise.success (response) ->
            $rootScope.$broadcast "user.logout"
            sessionService.currentUser = null
            $http.defaults.headers.common['X-CSRF-Token'] = response.csrfToken
        responsePromise

    sessionService.register = (email, password, password_confirmation) ->
        responsePromise = $http.post 'users.json',
            user:
                email: email
                password: password
                password_confirmation: password_confirmation
        responsePromise.success (response) ->
            sessionService.currentUser = response
            $rootScope.$broadcast "user.login"
        responsePromise

    sessionService.requestCurrentUser = () ->
        if sessionService.isAuthenticated()
            $q.when sessionService.currentUser
        else
            $http.get('/user.json').then (response) ->
                if response.data.signed_in
                    sessionService.currentUser = response.data.user
                else
                    sessionService.currentUser = null

                sessionService.currentUser

    sessionService
]

