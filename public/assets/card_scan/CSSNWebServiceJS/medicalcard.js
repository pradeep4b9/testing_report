$(document).ready(function () {

    var blobFrontImage;
    var blobBackImage;

    $('input[type="checkbox"]').not('#create-switch').bootstrapSwitch();
    $("#rdoFront").prop("checked", true)
    $("#rdoFront").parent().addClass("active");

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
    var blankCanvasFront = document.querySelector('#blank-canvas-front');
    var blankContextFront = blankCanvasFront.getContext('2d');
    var selectedCanvasFront = document.querySelector('#selected-canvas-front');
    var selectedCanvasBack = document.querySelector('#selected-canvas-back');
    var contextCapturedCanvas = capturedcanvas.getContext('2d');

    var contextCanvasBack = selectedCanvasBack.getContext('2d');

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

        $("#help-icon").tooltip({ placement: 'bottom' });
        $('#chkPreProcessing').bootstrapSwitch('setState', false);
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

    function onFailure(err) {
        //The developer can provide any alert messages here once permission is denied to use the webcam.
    }

    function cloneCanvas(oldCanvas) {
        var newCanvas;

        if ($("#rdoFront").parent().hasClass("active"))
            newCanvas = document.querySelector('#selected-canvas-front');
        else
            newCanvas = document.querySelector('#selected-canvas-back');
        //create a new canvas
        //var newCanvas = document.createElement('canvas');
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
        document.getElementById("extractedData").style.display = "none";
        $('#medicalcard-data').empty();
    };

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

    //Accept captured image from webcam and display on canvas.
    $("#btn-use-image").click(function () {
        cloneCanvas(capturedcanvas);
        $('#myModal').modal("hide");
    });

    //Clicks on webcam area to capture image.
    $("#webcam").click(function () {
        snapshot();
        $('#myModal').modal()
        $("#div-controls").show();
    });

    //Clears controls and opens File Dialog to chose input image
    $("#placehold-image-front").click(function () {
        $("#input-image-front").click();
        document.getElementById("extractedData").style.display = "none";
        $('#medicalcard-data').empty();
        $('#loading').empty();
    });

    //Clears controls and opens File Dialog to chose input image
    $("#placehold-image-back").click(function () {
        $("#input-image-back").click();
        document.getElementById("extractedData").style.display = "none";
        $('#medicalcard-data').empty();
        $('#loading').empty();
    });

    //Clears controls and opens File Dialog after choosing an input image
    $("#image-thumbnail-front").click(function () {
        $("#input-image-front").click();
        document.getElementById("extractedData").style.display = "none";
        $('#medicalcard-data').empty();
        $('#errorDiv').empty();
        $('#loading').empty();
        $("#div-controls").show();
    });

    //Clears controls and opens File Dialog after choosing an input image
    $("#image-thumbnail-back").click(function () {
        $("#input-image-back").click();
        document.getElementById("extractedData").style.display = "none";
        $('#medicalcard-data').empty();
        $('#errorDiv').empty();
        $('#loading').empty();
        $("#div-controls").show();
    });

    //Resize image
    $('#input-image-front').change(function (e) {
        var file = e.target.files[0];

        canvasResize(file, {
            crop: false,
            quality: 80,
            callback: function (data, width, height) {
                blobFrontImage = dataURLtoBlob(data);
            }
        });
    });

    //Resize image
    $('#input-image-back').change(function (e) {
        var file = e.target.files[0];

        canvasResize(file, {
            crop: false,
            quality: 80,
            callback: function (data, width, height) {
                blobBackImage = dataURLtoBlob(data);
            }
        });
    });

    $("#btn-process-image").click(function () {

        ResetControls();
        var isSourceCameraOrDisk = $('#chkImageSource').is(':checked') ? true : false;
        var usePreprocessing = $('#chkPreProcessing').is(':checked') ? true : false;

        var imageToProcess;
        var imgValFront = $('#input-image-front').val();
        var imgValBack = $('#input-image-back').val();

        $('#diplay-div').empty();
        $('#div-img').empty();

        $('#errorDiv').empty();
        $('#loading').empty();

        var dataUrl;
        var image;

        if (isSourceCameraOrDisk) {
            if (imgValFront == '') {
                alert("Front side image required.");
                return;
            }

            imageToProcess = new FormData();
            imageToProcess.append("frontImage", blobFrontImage);

            if (imgValBack != '')
                imageToProcess.append("backImage", blobBackImage);
        }
        else {
            imageToProcess = new FormData();
            dataUrl = selectedCanvasFront.toDataURL();
            image = dataURLtoBlob(dataUrl);
            var blankDataUrl = blankCanvasFront.toDataURL();

            if (dataUrl == blankDataUrl) {
                alert("Capture image first before processing.");
                return;
            }
            //imageToProcess = image;
            imageToProcess.append("files", image);


            dataUrl = selectedCanvasBack.toDataURL();

            if (dataUrl != blankDataUrl) {
                image = dataURLtoBlob(dataUrl);
                imageToProcess.append("files", image);
            }
        }

        //Accesing the web service 
        $.ajax({
            type: "POST",
            url: "https://cssnwebservices.com/CSSNService/CardProcessor/ProcessMedInsuranceCard/true/0/150/" + usePreprocessing.toString(),
            data: imageToProcess,
            cache: false,
            contentType: 'application/octet-stream; charset=utf-8;',
            dataType: "json",
            processData: false,
            beforeSend: function (xhr) {
                xhr.setRequestHeader("Authorization", "LicenseKey " + authinfo);
                $('#loading').html("<img src='images/processing.gif'/>");
                $("#div-controls").hide();
            },
            success: function (data) {

                var medicalCard = JSON.stringify(data);
                medicalCard = jQuery.parseJSON(medicalCard);


                if (medicalCard.ResponseCodeAuthorization < 0) {
                    $('#errorDiv').html("<p>CSSN Error Code: " + medicalCard.ResponseMessageAuthorization + "</p>");
                }
                else if (medicalCard.WebResponseCode < 1) {
                    $('#errorDiv').html("<p>CSSN Error Code: " + medicalCard.WebResponseDescription + "</p>");
                }
                else {

                    //Display data returned by the web service
                    var data = AddDisplay("MemberName", medicalCard.MemberName);
                    data += AddDisplay("NameSuffix", medicalCard.NameSuffix);
                    data += AddDisplay("NamePrefix", medicalCard.NamePrefix);
                    data += AddDisplay("FirstName", medicalCard.FirstName);
                    data += AddDisplay("MiddleName", medicalCard.MiddleName);
                    data += AddDisplay("LastName", medicalCard.LastName);
                    data += AddDisplay("MemberId", medicalCard.MemberId);
                    data += AddDisplay("GroupNumber", medicalCard.GroupNumber);
                    data += AddDisplay("ContractCode", medicalCard.ContractCode);
                    data += AddDisplay("CopayEr", medicalCard.CopayEr);
                    data += AddDisplay("CopayOv", medicalCard.CopayOv);
                    data += AddDisplay("CopaySp", medicalCard.CopaySp);
                    data += AddDisplay("CopayUc", medicalCard.CopayUc);
                    data += AddDisplay("Coverage", medicalCard.Coverage);
                    data += AddDisplay("DateOfBirth", medicalCard.DateOfBirth);
                    data += AddDisplay("Deductible", medicalCard.Deductible);
                    data += AddDisplay("EffectiveDate", medicalCard.EffectiveDate);
                    data += AddDisplay("Employer", medicalCard.Employer);
                    data += AddDisplay("ExpirationDate", medicalCard.ExpirationDate);
                    data += AddDisplay("GroupName", medicalCard.GroupName);
                    data += AddDisplay("IssuerNumber", medicalCard.IssuerNumber);
                    data += AddDisplay("Other", medicalCard.Other);
                    data += AddDisplay("PayerId", medicalCard.PayerId);
                    data += AddDisplay("PlanAdmin", medicalCard.PlanAdmin);
                    data += AddDisplay("PlanProvider", medicalCard.PlanProvider);
                    data += AddDisplay("PlanType", medicalCard.PlanType);
                    data += AddDisplay("RxBin", medicalCard.RxBin);
                    data += AddDisplay("RxGroup", medicalCard.RxGroup);
                    data += AddDisplay("RxId", medicalCard.RxId);
                    data += AddDisplay("RxPcn", medicalCard.RxPcn);

                    var addressCount = medicalCard.ListAddress.length;
                    if (addressCount > 0) {
                        for (var i = 0; i < addressCount; i++) {
                            data += AddDisplay("Full Address (" + (i + 1) + ") ", medicalCard.ListAddress[i].FullAddress);
                            data += AddDisplay("Street (" + (i + 1) + ")", medicalCard.ListAddress[i].Street);
                            data += AddDisplay("City (" + (i + 1) + ")", medicalCard.ListAddress[i].City);
                            data += AddDisplay("State (" + (i + 1) + ")", medicalCard.ListAddress[i].State);
                            data += AddDisplay("Zip (" + (i + 1) + ")", medicalCard.ListAddress[i].Zip);
                        }
                    }

                    var webCount = medicalCard.ListWeb.length;
                    if (webCount > 0) {
                        for (var i = 0; i < webCount; i++) {
                            data += AddDisplay("Web (" + (i + 1) + ")", medicalCard.ListWeb[i].Label == "" ? medicalCard.ListWeb[i].Value : medicalCard.ListWeb[i].Label + " - " + medicalCard.ListWeb[i].Value);
                        }
                    }

                    var emailCount = medicalCard.ListEmail.length;
                    if (emailCount > 0) {
                        for (var i = 0; i < emailCount; i++) {
                            data += AddDisplay("Email (" + (i + 1) + ")", medicalCard.ListEmail[i].Label == "" ? medicalCard.ListEmail[i].Value : medicalCard.ListEmail[i].Label + " - " + medicalCard.ListEmail[i].Value);
                        }
                    }

                    var telephoneCount = medicalCard.ListTelephone.length;
                    if (telephoneCount > 0) {
                        for (var i = 0; i < telephoneCount; i++) {
                            data += AddDisplay("Telephone (" + (i + 1) + ")", medicalCard.ListTelephone[i].Label == "" ? medicalCard.ListTelephone[i].Value : medicalCard.ListTelephone[i].Label + " - " + medicalCard.ListTelephone[i].Value);
                        }
                    }

                    var deductibleCount = medicalCard.ListDeductible.length;
                    if (deductibleCount > 0) {
                        for (var i = 0; i < deductibleCount; i++) {
                            data += AddDisplay("Deductible (" + (i + 1) + ")", medicalCard.ListDeductible[i].Label == "" ? medicalCard.ListDeductible[i].Value : medicalCard.ListDeductible[i].Label + " - " + medicalCard.ListDeductible[i].Value);
                        }
                    }

                    var planCodeCount = medicalCard.ListPlanCode.length;
                    if (planCodeCount > 0) {
                        for (var i = 0; i < planCodeCount; i++) {
                            data += AddDisplay("PlanCode (" + (i + 1) + ")", medicalCard.ListPlanCode[i].PlanCode);
                        }
                    }

                    $(data).appendTo("#medicalcard-data");
                    document.getElementById("extractedData").style.display = "inline";
                }

                //Display reformatted images on UI
                var reformattedImageFront = medicalCard.ReformattedImage;
                if (reformattedImageFront != null) {
                    var base64ReformattedImage = goog.crypt.base64.encodeByteArray(reformattedImageFront);
                    document.getElementById("extractedData").style.display = "inline";
                    $("#image-thumbnail-front img:first-child").attr("src", "data:image/png;base64," + base64ReformattedImage);
                }

                var reformattedImageBack = medicalCard.ReformattedImageTwo;
                if (reformattedImageBack != null) {
                    var base64ReformattedImage = goog.crypt.base64.encodeByteArray(reformattedImageBack);
                    document.getElementById("extractedData").style.display = "inline";
                    $("#image-thumbnail-back img:first-child").attr("src", "data:image/png;base64," + base64ReformattedImage);
                }

            },
            error: function (xhr, err) {
                alert("readyState: " + xhr.readyState + "\nstatus: " + xhr.status);
                alert("responseText: " + xhr.responseText);
                $("#div-controls").hide();
            },
            complete: function (e) {
                $('#loading').html("");
                $("#div-controls").hide();
            }
        });
    });

});