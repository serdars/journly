xplanLoginController = angular.module "xplanLoginController", [ ]

xplanLoginController.controller "loginController", [ '$scope', '$rootScope', '$timeout', 'XplanSession', '$stateParams', 'currentUser', ($scope, $rootScope, $timeout, XplanSession, $stateParams, currentUser) ->
    resetErrors = () ->
        $scope.errors =
            email: [ ]
            password: [ ]
            password_confirmation: [ ]
    resetErrors()
    
    $scope.registerUser = () ->
        resetErrors()
        XplanSession.register($scope.registerEmail, $scope.registerPassword, $scope.registerPasswordConfirmation).success (response) ->
            console.log "we will now redirect"
        .error (response) ->
            angular.forEach response.errors, (value, key) ->
                $scope.errors[key].push key + " " + value[0]
]
