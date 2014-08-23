$(document).ready(function () {

    var blobImage;

    //Convert checkbox to switch type
    $('input[type="checkbox"]').not('#create-switch').bootstrapSwitch();

    //Detect type of device.
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

    //These variables are for capturing images using webcam.
    //The images captured should be copied to the canvas to keep their resolutions.
    var video = document.querySelector('#webcam');
    var capturedcanvas = document.querySelector('#captured-canvas');
    var blankCanvas = document.querySelector('#blank-canvas');
    var blankContext = blankCanvas.getContext('2d');
    var selectedCanvas = document.querySelector('#selected-canvas');
    var contextCapturedCanvas = capturedcanvas.getContext('2d');


    if (isMobile.any()) {
        $("#option-source").hide();
        $("#container-camera").show();
        $("#container-webcam").hide();
        $('#chkPreProcessing').bootstrapSwitch('setState', true);
    }
    else {

        //Change to .show() to enable webcam feature.
        $("#option-source").hide();

        //Remove comment to enable webcam feature
        //Prompts the user for permission to use a webcam.
        //        navigator.getUserMedia = (navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia || navigator.msGetUserMedia);
        //        if (navigator.getUserMedia) {
        //            navigator.getUserMedia
        //                            (
        //                              { video: true },
        //                              function (localMediaStream) {
        //                                  video.src = window.URL.createObjectURL(localMediaStream);
        //                              }, onFailure);
        //        }

        //        $("#help-icon").tooltip({ placement: 'bottom' });
        //        $('#chkPreProcessing').bootstrapSwitch('setState', false);
    }

    //Toggles UI between using fileupload or webcam as image input
    var isSourceCameraOrDisk = $('#chkImageSource').is(':checked') ? true : false;
    if (isSourceCameraOrDisk) {
        $("#container-camera").show();
        $("#container-webcam").hide();
    }
    else {
        $("#container-camera").hide();
        $("#container-webcam").show();
    }

    //Toggles UI between using fileupload or webcam when the checkbox has been changed.
    $("#chkImageSource").change(function () {
        if (this.checked) {
            $("#container-camera").show()
            $("#container-webcam").hide()
        }
        else {
            $("#container-camera").hide()
            $("#container-webcam").show()
        }
    });

    function onFailure(err) {
        //The developer can provide any alert messages here once permission is denied to use the webcam.
    }

    function cloneCanvas(oldCanvas) {

        //create a new canvas
        var newCanvas = document.querySelector('#selected-canvas');
        var context = newCanvas.getContext('2d');

        //set dimensions
        newCanvas.width = oldCanvas.width;
        newCanvas.height = oldCanvas.height;

        //apply the old canvas to the new one
        context.drawImage(oldCanvas, 0, 0);

        //return the new canvas
        return newCanvas;
    }

    //Display the image to the canvas upon capturing image from webcam.
    function snapshot() {
        capturedcanvas.width = video.videoWidth;
        capturedcanvas.height = video.videoHeight;
        contextCapturedCanvas.drawImage(video, 0, 0);
    }

    // Convert dataURL to Blob object
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

    //Format data displayed to UI.
    function AddDisplay(fieldName, fieldValue) {

        var string = "<div class=\"form-group\">";
        string += "<label class=\"col-md-4 control-label\">";
        string += fieldName;
        string += "</label>";
        string += "<div class=\"col-md-7\">";
        string += "<p class=\"form-control text-center\">";
        string += fieldValue;
        string += "</p>";
        string += "</div>";
        string += "</div>";
        return string;
    };

    //Clears populated controls. Prepares UI for next processing.
    function ResetControls() {
        $("#reformatted-image").attr("src", "http://www.placehold.it/350x120/EFEFEF/AAAAAA&text=no+image");
        document.getElementById("extractedData").style.display = "none";
        $("#main-image").attr("src", "http://www.placehold.it/507x318/EFEFEF/AAAAAA&text=Tap+Here");
        $('#barcode-data').empty();
    };

    //Accept captured image from webcam and display on canvas.
    $("#btn-use-image").click(function () {
        cloneCanvas(capturedcanvas);
        $('#myModal').modal("hide");
        $("#div-controls").show();
    });

    //Clicks on webcam area to capture image.
    $("#webcam").click(function () {
        snapshot();
        $('#myModal').modal()
    });

    //Clears controls and opens File Dialog to chose input image
    $("#placehold-image").click(function () {
        $("#input-image").click();
        document.getElementById("extractedData").style.display = "none";
        $('#barcode-data').empty();
        $('#errorDiv').empty();
        $('#loading').empty();
        $("#div-controls").show();
    });

    //Clears controls and opens File Dialog after choosing an input image
    $("#image-thumbnail").click(function () {
        $("#input-image").click();
        document.getElementById("extractedData").style.display = "none";
        $('#barcode-data').empty();
        $('#errorDiv').empty();
        $('#loading').empty();
        $("#div-controls").show();
    });

    //Resize image
    $('#input-image').change(function (e) {
        var file = e.target.files[0];

        canvasResize(file, {
            crop: false,
            quality: 80,
            callback: function (data, width, height) {
                blobImage = dataURLtoBlob(data);
            }
        });
    });

    $("#btn-process-image").click(function () {

        ResetControls();
        var isSourceCameraOrDisk = $('#chkImageSource').is(':checked') ? true : false;
        var usePreprocessing = $('#chkPreProcessing').is(':checked') ? true : false;

        var selectedRegion = $("#region-select").val();
        var imageToProcess;
        var imgVal = $('#input-image').val();

        $('#diplay-div').empty();
        $('#div-img').empty();

        $('#errorDiv').empty();
        $('#loading').empty();

        if (isSourceCameraOrDisk) {
            if (imgVal == '') {
                alert("Empty input file.");
                return;
            }

            imageToProcess = blobImage;
        }
        else {
            var dataUrl = selectedCanvas.toDataURL();
            var image = dataURLtoBlob(dataUrl);
            var blankDataUrl = blankCanvas.toDataURL();

            if (dataUrl == blankDataUrl) {
                alert("Capture image first before processing.");
                return;
            }
            imageToProcess = image;
        }

        //Accesing the web service 
        $.ajax({
            type: "POST",
            url: "https://cssnwebservices.com/CSSNService/CardProcessor/ProcessBarcode/true/0/200/" + usePreprocessing.toString(),
            data: imageToProcess,
            cache: false,
            contentType: 'application/octet-stream; charset=utf-8;',
            dataType: "json",
            processData: false,
            beforeSend: function (xhr) {
                xhr.setRequestHeader("Authorization", "LicenseKey " + authinfo); $('#loading').html("<img src='/assets/processing.gif'/>");
                $("#div-controls").hide();
            },
            success: function (data) {

                //Convert data to string before parsing
                var barcode = JSON.stringify(data);
                barcode = jQuery.parseJSON(barcode);

                //Checking if there are errors returned.
                if (barcode.ResponseCodeAuthorization < 0) {
                    $('#errorDiv').html("<p>CSSN Error Code: " + barcode.ResponseMessageAuthorization + "</p>");
                }
                else if (barcode.WebResponseCode < 1) {
                    $('#errorDiv').html("<p>CSSN Error Code: " + barcode.WebResponseDescription + "</p>");

                }
                else if (barcode.ResponseCodeProcBarcode <= 0) {
                    if (barcode.Results2D > 0) {
                        $('#errorDiv').html("<p>CSSN Error Code: 2D Barcode found but not read.</p>");
                    }
                    else {
                        $('#errorDiv').html("<p>CSSN Error Code : " + barcode.ResponseCodeProcBarcodeDesc + "</p>");
                    }
                }
                else {

                    //Display data returned by the web service
                    var data = AddDisplay("Name", barcode.Name);
                    data += AddDisplay("NameFirst", barcode.NameFirst);
                    data += AddDisplay("NameMiddle", barcode.NameMiddle);
                    data += AddDisplay("NameSuffix", barcode.NameSuffix);
                    data += AddDisplay("NameLast", barcode.NameLast);
                    data += AddDisplay("license", barcode.license);
                    data += AddDisplay("IssueDate", barcode.IssueDate);
                    data += AddDisplay("DateOfBirth", barcode.DateOfBirth);
                    data += AddDisplay("Address", barcode.Address);
                    data += AddDisplay("City", barcode.City);
                    data += AddDisplay("State", barcode.State);
                    data += AddDisplay("Zip", barcode.Zip);
                    data += AddDisplay("ExpirationDate", barcode.ExpirationDate);
                    data += AddDisplay("Class", barcode.Class);
                    data += AddDisplay("Sex", barcode.Sex);
                    data += AddDisplay("SocialSecurity", barcode.SocialSecurity);
                    data += AddDisplay("Eyes", barcode.Eyes);
                    data += AddDisplay("Hair", barcode.Hair);
                    data += AddDisplay("Height", barcode.Height);
                    data += AddDisplay("Weight", barcode.Weight);

                    $(data).appendTo("#barcode-data");
                    document.getElementById("extractedData").style.display = "inline";
                }

                //Display reformatted image on UI
                var reformattedImage = barcode.ReformattedImage;
                if (reformattedImage != null) {
                    var base64ReformattedImage = goog.crypt.base64.encodeByteArray(reformattedImage);
                    $("#image-thumbnail img:first-child").attr("src", "data:image/png;base64," + base64ReformattedImage);
                }
            },
            error: function (e) {
                $('#errorDiv').html("Error: " + e);
                $("#div-controls").hide();
            },
            complete: function (e) {
                $('#loading').html(""); $("#div-controls").show();
                $("#div-controls").hide();
            }
        });
    });
});