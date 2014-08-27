$(document).ready(function(){



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
      $("#formSubmit").attr("action","/card_scans/voice")
      document.forms["formSubmit"].submit();
     
     }
  });          

})