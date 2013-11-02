xplanControllers = angular.module "xplanControllers", [ ]
    
xplanControllers.controller "itemListController", [ '$scope', '$rootScope', 'XplanData', ($scope, $rootScope, XplanData) ->
    $scope.items = XplanData.items
    
    $scope.launchItemCreate = () ->
        $rootScope.$broadcast 'item.create'

    $scope.deleteItem = (item) ->
        XplanData.deleteItem item

    $scope.editItem = (item) ->
        $rootScope.$broadcast 'item.edit', item
]
    
xplanControllers.controller "itemCreationController", [ '$scope', '$rootScope', 'XplanData', ($scope, $rootScope, XplanData) ->
    $('#addItemModal').modal
        show: false

    $rootScope.$on "item.create", () ->
        $scope.item = null
        $('#addItemModal').modal "show"

    $rootScope.$on "item.edit", (event, item) ->
        $scope.item = item
        $('#addItemModal').modal "show"
    
    $scope.submitItem = () ->
        if $scope.item == null
            XplanData.createItem
                title: $scope.item_title
                details: $scope.item_details
        else
            XplanData.editItem $scope.item,
                title: $scope.item_title
                details: $scope.item_details

    $scope.buttonMessage = () ->
        if $scope.item != null
            "Edit"
        else
            "Add"
]
