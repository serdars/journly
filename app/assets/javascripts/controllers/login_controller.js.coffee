xplanLoginController = angular.module "xplanLoginController", [ ]

xplanLoginController.controller "loginController", [ '$scope', '$rootScope', '$timeout', 'XplanSession', '$stateParams', 'currentUser', '$state', ($scope, $rootScope, $timeout, XplanSession, $stateParams, currentUser, $state) ->
    resetErrors = () ->
        $scope.errors =
            email: [ ]
            password: [ ]
            password_confirmation: [ ]
        $scope.loginError = null
    resetErrors()

    redirect = () ->
        target = 'plans'
        if $stateParams.target
            target = $stateParams.target
        $state.transitionTo target

    if currentUser != null
        redirect()

    $scope.loginUser = () ->
        resetErrors()
        XplanSession.login($scope.loginEmail, $scope.loginPassword).success (response) ->
            redirect()
        .error (response) ->
            $scope.loginError = response.error

    $scope.registerUser = () ->
        resetErrors()
        XplanSession.register($scope.registerEmail, $scope.registerPassword, $scope.registerPasswordConfirmation).success (response) ->
            redirect()
        .error (response) ->
            angular.forEach response.errors, (value, key) ->
                $scope.errors[key].push key + " " + value[0]
]
