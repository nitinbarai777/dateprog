// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require bootstrap
//= require turbolinks
//= require contact_me
//= require main
//= require jqBootstrapValidation
//= require jqconsole
//= require jquery.jscroll
//= require jquery.range-min
//= require jquery.lazyload
//= require chat
//= require jquery.playSound
//= require slidepushmenu/modernizr.custom
//= require slidepushmenu/classie
//= require jquery.blueimp-gallery.min
//= require bootstrap-image-gallery.min
//= require bootstrap2-toggle.min
//= require jquery.remotipart
//= require autocomplete-rails
//= require ckeditor/init
//= require ckeditor/config
//= require jquery.zoom.min
	
$(document).on("ready, page:change","",function() {	
	
	$('.chatboxtextarea').click(function (e) {
		$( "body .portfolio-modal" ).each(function( ) {
			if($(this).css('display') == 'block'){ 
				var p_id = $(this).attr('id');
				var close_lnk = "#" + p_id + " #close_modal a";
				$('#'+p_id).modal('hide');

			}
		});
		e.preventDefault();
		setTimeout(function() {
		    $(this).focus();
		}, 200);
	});

	
	$("#notify-message-link").click(function (e) {
		$('.notify-profile').hide();
		$(".notify-message").toggle("slow");
	});

/*
  $("#showLeftPush, #showLeftPushArow").click(function (e) {
		//$("#notification-profile").toggle();
		referral_code = $("#referral-code").html();
		track_google_analytics("filter", referral_code);
	});
*/
	$("#showRightPush").click(function (e) {
		referral_code = $("#referral-code").html();
		track_google_analytics("message", referral_code);
	});

	$("#blueimp-gallery h3").click(function (e) {
		var title = $(this).html().split('-');
		window.open($.trim(title.pop()), '_blank');
	});

 	$('#notify-profile').change(function() { 
		$.ajax({
		  url: "/notify_profile",
		  cache: false,
		  success: function(data) {}
		}); 		
 	});

	$("#avatar_thumb").click(function (e) {
		$('#avatar').click();
	});

	$("#avatar_thumb1").click(function (e) {
		$('#avatar1').click();
	});
	
	$("#avatar_thumb2").click(function (e) {
		$('#avatar2').click();
	});			

	$("#main-container").css({"padding-bottom":$(".footer").outerHeight(), "min-height":$(window).outerHeight()});
	$("#page-top").css({"padding-bottom":$(".footer").outerHeight(), "min-height":$(window).outerHeight()});
	
	leftMenuHeight();
	consoleHeight();
	
    $("#profileTabs a").click(function(e){
        e.preventDefault();
        $(this).tab('show');
    });
    
    $("body a").click(function(e){
    	if ($(this).attr('id') == "loader") {
        	$("#main-loader-image").show();
       }
    });
    $("body button").click(function(e){
    	if ($(this).attr('id') == "loader") {
        	$("#main-loader-image").show();
       }
    });    

	//var client = new Faye.Client("#{FAYE_URL}/faye");

	//resizable div
 	var resizeOpts = { 
      handles: 'e, w'
    }; 	
	$( "#resizable" ).resizable(resizeOpts);

	$(".modal-content #close_modal").click(function(){
		sender_id = $("#sender_id").val();
		recipient_id = $("#recipient_id").val();
		if (sender_id && recipient_id) {
			var client = new Faye.Client("https://dateprogfaye.herokuapp.com/faye");
			client.unsubscribe('/messages/public/'+sender_id+'/'+recipient_id);
		}	
		$( "#chat-room-header" ).remove();
	});	
	
	$("#traits").click(function(){
		$("#find_a_mate").attr("tabindex",-1).focus();
	});
	$("#traits").click(function(){
		$("#find_a_mate").attr("tabindex",-1).focus();
	});

	
	$("#filter-btn, #contact-profile-btn").click(function(){
	  $("#loader-image").show();
	});	
	
	
  $("#avatar").change(function(){
  	  $("#image-loader").show();
      readURL(this);
      $(this).closest('form').submit();
  });

  
  $("#avatar1").change(function(){
  	  $("#image-loader1").show();
      readURLAvatar1(this);
      $(this).closest('form').submit();
  });
  
  $("#avatar2").change(function(){
  	  $("#image-loader2").show();
      readURLAvatar2(this);
      $(this).closest('form').submit();
  });	    	  

  $('.range-slider').jRange({
      from: 18,
      to: 70,
      step: 1,
      scale: [18,20,25,30,35,40,45,50],
      format: '%s',
      width: 150,
      showLabels: true,
      isRange : true,
      theme: "theme-blue"
  });
/*
	$('#course_level_answer').keyup(function() {
	  var len = $(this).val().length;
	  if (len >= 3 && $('#course_level_regular_expression').is(":checked")) {
	    $("#regexp_tips").show("fast");
	  } else {
	    $("#regexp_tips").hide("fast");
	  }
	});  
*/

	$('#course_level_regular_expression').click(function() {
	  if ($('#course_level_regular_expression').is(":checked")) {
	    $("#regexp_tips").show("fast");
	  } else {
	    $("#regexp_tips").hide("fast");
	  }
	});  
  
});	

function disableOther( button ) {
	if( button == 'showLeftPush' ) {
		classie.toggle( showRightPush );
	}
	if( button == 'showRightPush' ) {
		if (showLeftPush != "") {
			classie.toggle( showLeftPush );
		}
	}
}

function readURLAvatar1(input) {
  if (input.files && input.files[0]) {
  	var f = input.files[0];
  	var t = f.type;
  	var s = f.size;
  	if (t == "image/gif" || t == "image/jpeg" || t == "image/png") {
  		if (s < 5000000) {
		    var reader = new FileReader();
		    reader.onload = function (e) {
		        $('#avatar_thumb1').attr('src', e.target.result);
				$("#photo-error-size-msg1").hide();
				$("#photo-error-type-msg1").hide();
		        $("#photo-save-msg1").show();
		    }
		    reader.readAsDataURL(input.files[0]);
		} else {
			$("#image-loader1").hide();
			$('#avatar_thumb1').attr('src', "noimage.gif");
			$("#photo-save-msg1").hide();
			$("#photo-error-type-msg1").hide();
			$("#photo-error-size-msg1").show();
		}    
	} else {
		$("#image-loader1").hide();
		$('#avatar_thumb1').attr('src', "noimage.gif");
		$("#photo-save-msg1").hide();
		$("#photo-error-size-msg1").hide();
		$("#photo-error-type-msg1").show();
	}    
  }
}

function readURLAvatar2(input) {
  if (input.files && input.files[0]) {
  	var f = input.files[0];
  	var t = f.type;
  	var s = f.size;
  	if (t == "image/gif" || t == "image/jpeg" || t == "image/png") {
  		if (s < 5000000) {
		    var reader = new FileReader();
		    reader.onload = function (e) {
		        $('#avatar_thumb2').attr('src', e.target.result);
				$("#photo-error-size-msg2").hide();
				$("#photo-error-type-msg2").hide();
		        $("#photo-save-msg1").show();
		    }
		    reader.readAsDataURL(input.files[0]);
		} else {
			$("#image-loader2").hide();
			$('#avatar_thumb2').attr('src', "noimage.gif");
			$("#photo-save-msg2").hide();
			$("#photo-error-type-msg2").hide();
			$("#photo-error-size-msg2").show();
		}    
	} else {
		$("#image-loader2").hide();
		$('#avatar_thumb2').attr('src', "noimage.gif");
		$("#photo-save-msg2").hide();
		$("#photo-error-size-msg2").hide();
		$("#photo-error-type-msg2").show();
	}    
  }
}

function readURL(input) {
  if (input.files && input.files[0]) {
  	var f = input.files[0];
  	var t = f.type;
  	var s = f.size;
  	if (t == "image/gif" || t == "image/jpeg" || t == "image/png") {
  		if (s < 2500000) {
		    var reader = new FileReader();
		    reader.onload = function (e) {
		        $('#avatar_thumb').attr('src', e.target.result);
				$("#photo-error-size-msg").hide();
				$("#photo-error-type-msg").hide();
		        $("#photo-save-msg").show();
		    }
		    reader.readAsDataURL(input.files[0]);
		} else {
			$("#photo-success").hide();
			$("#image-loader").hide();
			$('#avatar_thumb').attr('src', "noimage.gif");
			$("#photo-save-msg").hide();
			$("#photo-error-type-msg").hide();
			$("#photo-error-size-msg").show();
		}    
	} else {
		$("#image-loader").hide();
		$("#photo-success").hide();
		$('#avatar_thumb').attr('src', "noimage.gif");
		$("#photo-save-msg").hide();
		$("#photo-error-size-msg").hide();
		$("#photo-error-type-msg").show();
	}    
  }
}
    


function hide_messages (recipient_id, message_id) {
  if (message_id != "") {
    $("#div_update_"+recipient_id+"_"+message_id).empty();
  } else {
  	$("#div_update_"+recipient_id).empty();
  }  
}

function next_traits (k, c) {
	$(".traits_"+k).hide();
	k = k + 1;
	$(".traits_"+k).show();
	
	if (k == c) {
		$("#loader-image").show();
		$("#find_a_mate").prop("disabled", false);
		$('#find_a_mate').trigger('click');
	}	
}

function uLoginFun(token){
   $.getJSON("//ulogin.ru/token.php?host=" +
       encodeURIComponent(location.toString()) + "&token=" + token + "&callback=?",
   function(data){
       data=$.parseJSON(data.toString());
       if(!data.error){
           window.location.href = '/sign_with_social?token='+token;
       }
   });
}

function select_all(el, current_user_id) {
		// select content in input
		el.select();

		track_google_analytics("copy-referral-link", current_user_id);
}

function progress(percent, $element, remain_duration) {
    var progressBarWidth = percent * $element.width() / 100;
    //$element.find('div').animate({ width: progressBarWidth }, 500).html(percent+"%-"+remain_duration+"");
    $element.find('div').animate({ width: progressBarWidth }, 500).html(percent+"%");
    if (percent > 66) {
    	$('.battery div').css('background-color','#66CD00');
    } else if (percent > 33) {
    	$('.battery div').css('background-color','#FCD116');
    } else {
    	$('.battery div').css('background-color','#FF3333');
    }
}

function leftMenuHeight(){
	var leftMenuHeight = $(window).outerHeight() - $(".navbar").outerHeight();
	$(".user-filter-form").css("height",leftMenuHeight-18);
}
function consoleHeight(){
	var value = $(window).outerHeight() - ($(".footer").outerHeight() + 110);
	var valueWidth = Math.round((value/3)*4);
/*
  if($(window).width() > 991){
		$('#console').css('height',value + 'px').css('width',valueWidth +'px');
	}else{
		$('#console').css('height',value + 'px').css('width',100 +'%');
	}
*/
  // set the console height and width (to 100%)
  $('#console').css('height',value + 'px').css('width',100 +'%');

}

function track_google_analytics(action, current_user_id, user_id) {
	(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
	 (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
	 m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
	 })(window,document,'script','//www.google-analytics.com/analytics.js','ga');
	 
	ga('create', 'UA-90121024-1', 'auto');
	ga('set', '&uid', current_user_id);	
	if (action == 'invite') {
		mixpanel.track("invitation:open-dialog");
 		ga('send', 'event', 'invitation', 'open-dialog');
	} else if (action == 'results_view_profile') {
		mixpanel.track("dashboard:results-view-profile");
		ga('send', 'event', 'dashboard', 'results-view-profile');
		$.ajax({
		  url: "/discharge_battery?user_id="+user_id,
		  cache: false,
		  success: function(data) {}
		});	

		setTimeout(function() {
		    $("#tip_"+user_id).show("slow");
		}, 3000);


	} else if (action == 'chat_open') {
		mixpanel.track("chat:open");
		ga('send', 'event', 'chat', 'open');
	} else if (action == 'filter') {
		mixpanel.track("dashboard:filter");
		ga('send', 'event', 'dashboard', 'filter');
	} else if (action == 'message') {
		mixpanel.track("dashboard:message");
		ga('send', 'event', 'dashboard', 'message');
	} else if (action == 'gmail') {
		mixpanel.track("invitation:share-email");
		ga('send', 'event', 'invitation', 'share-email');
	} else if (action == 'vkontakte') {
		mixpanel.track("invitation:share-vkontakte");
		ga('send', 'event', 'invitation', 'share-vkontakte');
	} else if (action == 'twitter') {
		mixpanel.track("invitation:share-twitter");
		ga('send', 'event', 'invitation', 'share-twitter');
	} else if (action == 'facebook') {
		mixpanel.track("invitation:share-facebook");
		ga('send', 'event', 'invitation', 'share-facebook');
	} else if (action == 'linkedin') {
		mixpanel.track("invitation:share-linkedin");
		ga('send', 'event', 'invitation', 'share-linkedin');
	} else if (action == 'copy-referral-link') {
		mixpanel.track("invitation:copy-referral-link");
		ga('send', 'event', 'invitation', 'copy-referral-link');
	} else if (action == 'notification') {
		if ($(this).is(":checked")) {
			mixpanel.track("email:chat-notification-subscribed");
			ga('send', 'event', 'email', 'chat-notification-subscribed');
		} else {
			mixpanel.track("email:chat-notification-unsubscribed");
			ga('send', 'event', 'email', 'chat-notification-unsubscribed');
		}
	}

	//if (action == 'gmail' || action == 'vkontakte' || action == 'twitter' || action == 'facebook' || action == 'linkedin') {
		//increase_battery_size("social_invite");
	//}
}

function increase_battery_size(action_type) {
	$.ajax({
	  url: "/increase_battery_size/"+action_type,
	  cache: false,
	  success: function(data) {}
	});
}

function verify_answer() {
  $('#test-ans').toggle();
  $('#course_level_test_answer').val($('#course_level_predefined_answer').val()); 
}

$(window).resize(function() {
	
	$("#main-container").css({"padding-bottom":$(".footer").outerHeight(), "min-height":$(window).outerHeight()});
	$("#page-top").css({"padding-bottom":$(".footer").outerHeight(), "min-height":$(window).outerHeight()});
	
	leftMenuHeight();
	consoleHeight();
});

