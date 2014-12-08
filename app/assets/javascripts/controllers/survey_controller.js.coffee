journlySurveyController = angular.module "journlySurveyController", [ ]

journlySurveyController.controller "surveyController", [ '$scope', '$rootScope', '$timeout',  ($scope, $rootScope, $timeout) ->
    $(window).resize () ->
        $("#sm_e_s").css "max-height", ($(window).height() - 51)

]
