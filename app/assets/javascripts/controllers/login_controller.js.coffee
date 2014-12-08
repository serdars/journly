journlyLoginController = angular.module "journlyLoginController", [ ]

journlyLoginController.controller "loginController", [ '$scope', '$rootScope', '$timeout', 'JournlySession', '$stateParams', 'currentUser', '$state', ($scope, $rootScope, $timeout, JournlySession, $stateParams, currentUser, $state) ->
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
        JournlySession.login($scope.loginEmail, $scope.loginPassword).success (response) ->
            redirect()
        .error (response) ->
            $scope.loginError = response.error

    $scope.registerUser = () ->
        resetErrors()
        JournlySession.register($scope.registerEmail, $scope.registerPassword, $scope.registerPasswordConfirmation).success (response) ->
            redirect()
        .error (response) ->
            angular.forEach response.errors, (value, key) ->
                $scope.errors[key].push key + " " + value[0]
]
