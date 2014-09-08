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
      $("#formSubmit").attr("action","/voices/record_voice")
      $("#formSubmit").attr("method","post")
      document.forms["formSubmit"].submit();
     
     }
  });          

})