$(document).ready ->    
  $(document).on 'click', '.btn-profile', (e) ->  
    $("#new_profile").validate()


  $(document).on 'change', '#profile_country', (e) ->  


    $.post "/country_code.json",
      country: $(this).val()
    , (data) ->
      $("#profile_mobile_ctry_code").val "+"+data.code
      return    
