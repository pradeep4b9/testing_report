var createBinaryFile = function(uintArray) {
    var data = new Uint8Array(uintArray);
    var file = new BinaryFile(data);
 
    file.getByteAt = function(iOffset) {
        return data[iOffset];
    };
 
    file.getBytesAt = function(iOffset, iLength) {
        var aBytes = [];
        for (var i = 0; i < iLength; i++) {
            aBytes[i] = data[iOffset  + i];
        }
        return aBytes;
    };
 
    file.getLength = function() {
        return data.length;
    };
 
    return file;
};

    function dataURLtoBlob(dataURL) {
        // Decode the dataURL    
        var binary = atob(dataURL.split(',')[1]);
        // Create 8-bit unsigned array
        var array = [];
        for (var i = 0; i < binary.length; i++) {
            array.push(binary.charCodeAt(i));
        }
        // Return our Blob object
        return new Blob([new Uint8Array(array)], { type: 'image/png' });
    }

$(document).ready(function ($) {

    var blobImage;

    

    var isMobile = {
        Android: function () {
            return navigator.userAgent.match(/Android/i);
        },
        BlackBerry: function () {
            return navigator.userAgent.match(/BlackBerry/i);
        },
        iOS: function () {
            return navigator.userAgent.match(/iPhone|iPad|iPod/i);
        },
        Opera: function () {
            return navigator.userAgent.match(/Opera Mini/i);
        },
        Windows: function () {
            return navigator.userAgent.match(/IEMobile/i);
        },
        any: function () {
            return (isMobile.Android() || isMobile.BlackBerry() || isMobile.iOS() || isMobile.Opera() || isMobile.Windows());
        }
    };




    $('#CamButtonMb').click(function() {
      $('#CamPicker').trigger('click');
      return false;
    });

    $('#CamPicker').on('change', function(e) {
            jQuery(document).lockpage();
            
            e.preventDefault();
            if(this.files.length === 0) return;
            var imageFile = this.files[0];
            var img = new Image();
            var url = window.URL ? window.URL : window.webkitURL;
            img.src = url.createObjectURL(imageFile);
            img.onload = function(e) {
                url.revokeObjectURL(this.src);
 
                var width;
                var height;
                var binaryReader = new FileReader();
                binaryReader.onloadend=function(d) {
                    var exif, transform = "none";
                    exif=EXIF.readFromBinaryFile(createBinaryFile(d.target.result));
 
                    if(exif.Orientation === 8) {
                        width = img.height;
                        height = img.width;
                        transform = "left";
                    } else if(exif.Orientation === 6) {
                        width = img.height;
                        height = img.width;
                        transform = "right";
                    } else if(exif.Orientation === 1) {
                        width = img.width;
                        height = img.height;
                    } else if(exif.Orientation === 3) {
                        width = img.width;
                        height = img.height;
                        transform = "flip";
                    } else {
                        width = img.width;
                        height = img.height;
                    }
                    var MAX_WIDTH = 1500;
                    var MAX_HEIGHT = 1500;
                    if (width/MAX_WIDTH > height/MAX_HEIGHT) {
                        if (width > MAX_WIDTH) {
                            height *= MAX_WIDTH / width;
                            width = MAX_WIDTH;
                        }
                    } else {
                        if (height > MAX_HEIGHT) {
                            width *= MAX_HEIGHT / height;
                            height = MAX_HEIGHT;
                        }
                    }
                    var canvas = $('#PhotoEdit')[0];
                    canvas.width = width;
                    canvas.height = height;
                    var ctx = canvas.getContext("2d");
                    ctx.fillStyle = 'white';
                    ctx.fillRect(0, 0, canvas.width, canvas.height);
                    if(transform === 'left') {
                        ctx.setTransform(0, -1, 1, 0, 0, height);
                        ctx.drawImage(img, 0, 0, height, width);
                    } else if(transform === 'right') {
                        ctx.setTransform(0, 1, -1, 0, width, 0);
                        ctx.drawImage(img, 0, 0, height, width);
                    } else if(transform === 'flip') {
                        ctx.setTransform(1, 0, 0, -1, 0, height);
                        ctx.drawImage(img, 0, 0, width, height);
                    } else {
                        ctx.setTransform(1, 0, 0, 1, 0, 0);
                        ctx.drawImage(img, 0, 0, width, height);
                    }
                    ctx.setTransform(1, 0, 0, 1, 0, 0);
                };
 
                binaryReader.readAsArrayBuffer(imageFile);
            };

            setTimeout(function(){
            var canvas = $('#PhotoEdit')[0];
            var ctx = canvas.getContext("2d");
            var pixels = ctx.getImageData(0, 0, canvas.width, canvas.height);
            var r, g, b, i;
            for (var py = 0; py < pixels.height; py += 1) {
                for (var px = 0; px < pixels.width; px += 1) {
                    i = (py*pixels.width + px)*4;
                    r = pixels.data[i];
                    g = pixels.data[i+1];
                    b = pixels.data[i+2];
                    if(g > 100 && g > r*1.35 && g > b*1.6) pixels.data[i+3] = 0;
                }
            }
            ctx.putImageData(pixels, 0, 0);
            var imageToProcess = canvas.toDataURL('image/png');
            console.log(imageToProcess);
            console.log(dataURLtoBlob(imageToProcess));



            $.post("/card_scans/canvas_capture",{image_data:imageToProcess},function(data){
                $('.re-capture-img').hide();
                $('.re-capture-cam').show();
                jQuery(".img-block img").attr('src',data);
                jQuery('#capture-img').bPopup({
                  speed: 650,
                  transition: 'slideIn',
                  onOpen: function() {
                    jQuery(document).unlockpage();
                      
                  },
                  onClose: function() {
                    $(".photo-pic-capture-loader").css('visibility','hidden');
                    $('.re-capture-cam').hide();
                    $('.re-capture-img').fadeIn().delay(500);
                  }
                        });
            }) }, 1000);

          
                    
            
            


    });


    
    if (isMobile.any()) {

        $("#CamButtonMb").show();
        $("#recapture").hide();
        $("#webcam").hide();
        $(".wpb_webcam.wpb_webcam-loader").hide();

    }

    

    jQuery.fn.lockpage =function(){

        jQuery("<div class='overlay-lockpage'><img src=\"/assets/preloader.gif\" width=\"50px\"></div>").insertAfter("body");

    }

    jQuery.fn.unlockpage =function(){

      setTimeout(function(){jQuery(".overlay-lockpage").remove();}, 800);
        
    }
});
