xplanApp = angular.module "xplanApp", [ ]

xplanApp.controller "XplanAppCtrl", ($scope, $http) ->
    $http.get('/plans/1/items').success (data) ->
        $scope.items = data
