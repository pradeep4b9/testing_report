$(document).ready ->    
  $(document).on 'click', '.btn-profile', (e) ->  
    $("#new_profile").validate()


  $(document).on 'change', '#profile_country', (e) ->  
    alert $(this).val()
