$(document).ready(function(){



  $('#verify_photo').click(function() {
    $("#formSubmit").attr("action","/photos/verify_status")
    $("#formSubmit").attr("method","post")
    $("#formSubmit").submit();
  });


  $('#CamButton').click(function() {
    $(".error").hide("slow").remove();  
    $('#CamPicker').trigger('click');
    return false;
  });

  $('#CamPicker').on('change', function(e) {
     var file = e.currentTarget.files[0];

     if(file.type.search("audio")=="-1"){
      $("<div class='error'>Only audio format is allowed</div>").insertBefore(".CamPicker");
      return false;
     }else{
      $(".voice-loader").show();
      $("#formSubmit").attr("action","/voices/record")
      $("#formSubmit").attr("method","post")
      document.forms["formSubmit"].submit();
     
     }
  });         

         jQuery(".policypopup,.termsandcondpopup").click(function () {
          if(jQuery(this).hasClass('policypopup')){
            jQuery(".termspolicy").hide();
            jQuery(".privacypolicy").show();
          }else{
            jQuery(".termspolicy").show();
            jQuery(".privacypolicy").hide();        
          }
        jQuery('#popup').bPopup({
              speed: 300,
              transition: 'fadeIn'
          });

          });
 

})