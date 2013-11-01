xplanApp = angular.module "xplanApp", [ ]

xplanApp.directive 'eatClick', () ->
    (scope, element, attrs) ->
        $(element).click (event) ->
            event.preventDefault();
xplanApp.config [ "$httpProvider", (provider) ->
    provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr 'content'
    ]
    
xplanApp.controller "XplanAppCtrl", ($scope, $http) ->
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
