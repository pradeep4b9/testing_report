$(document).ready ->    
  $(document).on 'click', '.termsandcondpopup,.policypopup', (e) ->
    if jQuery(this).hasClass("policypopup")
      jQuery(".termspolicy").hide()
      jQuery(".privacypolicy").show()
    else
      jQuery(".termspolicy").show()
      jQuery(".privacypolicy").hide()
    jQuery("#popup").bPopup
      speed: 300
      transition: "fadeIn"


  $(document).on 'click', '.btn-submit', (e) ->  
  	$("#new_user").validate()


