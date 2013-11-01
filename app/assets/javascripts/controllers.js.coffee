xplanControllers = angular.module "xplanControllers", [ ]
    
xplanControllers.controller "itemListController", ($scope, $http) ->
    $http.get('/plans/1/items').success (data) ->
        $scope.items = data

    $('#addItemModal').modal
        show: false

    $scope.launchItemCreate = () ->
        $('#addItemModal').modal "show"

    $scope.createItem = () ->
        $http.post '/plans/1/items',
            title: $scope.item_title
            details: $scope.item_details
        .success (item) ->
            $scope.items.push item
            $('#addItemModal').modal "hide"

xplanControllers.controller "itemCreationController", ($scope) ->
    # For now nothing
