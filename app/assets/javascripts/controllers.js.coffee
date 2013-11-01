xplanControllers = angular.module "xplanControllers", [ ]
    
xplanControllers.controller "itemListController", [ '$scope', '$rootScope', 'XplanData', ($scope, $rootScope, XplanData) ->
    $scope.items = XplanData.items
    $scope.launchItemCreate = () ->
        $rootScope.$broadcast 'item.create'
]
    
xplanControllers.controller "itemCreationController", [ '$scope', '$rootScope', 'XplanData', ($scope, $rootScope, XplanData) ->
    $('#addItemModal').modal
        show: false

    $rootScope.$on "item.create", () ->
        $('#addItemModal').modal "show"
    
    $scope.createItem = () ->
        XplanData.createItem
            title: $scope.item_title
            details: $scope.item_details
]
